import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import '../../data/models/gemini_analysis_result.dart';
import '../../data/models/user_profile.dart';

/// Manages the API connection to NVIDIA NIM (Meta Llama) and builds the 3-layer
/// Regulatory Intelligence Engine prompt dynamically.
///
/// For vision (image) scans, a 2-step approach is used:
///   Step 1 — Vision model extracts ingredient text from the image.
///   Step 2 — Text model (or local engine) performs the full regulatory analysis.
class GeminiService {
  GeminiService._();

  // ─── API Configuration ──────────────────────────────────────

  /// NVIDIA API key — pass via --dart-define=NVIDIA_API_KEY=<key>
  static const String _apiKey = String.fromEnvironment(
    'NVIDIA_API_KEY',
    defaultValue: '',
  );

  /// Whether the API is configured.
  static bool get isAvailable => _apiKey.isNotEmpty;

  static const _baseUrl =
      'https://integrate.api.nvidia.com/v1/chat/completions';

  /// Text model for structured analysis.
  static const _textModel = 'meta/llama-3.1-405b-instruct';

  /// Vision model for reading labels from images.
  static const _visionModel = 'meta/llama-3.2-90b-vision-instruct';

  // ─────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────

  /// Analyze ingredients text using the text model.
  /// Returns a structured analysis result, or null if unavailable.
  static Future<GeminiAnalysisResult?> analyze({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? productCategory,
    String? applicationType,
  }) async {
    if (!isAvailable) return null;

    final userMessage = _buildUserMessage(
      ingredientsText: ingredientsText,
      userProfile: userProfile,
      productName: productName,
      productCategory: productCategory,
      applicationType: applicationType,
    );

    final payload = {
      'model': _textModel,
      'messages': [
        {'role': 'system', 'content': _buildSystemPrompt()},
        {'role': 'user', 'content': userMessage},
      ],
      'temperature': 0.1,
      'top_p': 0.95,
      'max_tokens': 4096,
      // Force JSON output — this is the critical fix for Llama models
      'response_format': {'type': 'json_object'},
    };

    final text = await _callNvidia(payload);
    if (text == null) return null;

    final json = _extractJson(text);
    return GeminiAnalysisResult.fromJson(json);
  }

  /// Analyze an image using the vision model in a single pass.
  static Future<GeminiAnalysisResult?> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required UserProfile userProfile,
    String? productName,
    String? productCategory,
    String? applicationType,
  }) async {
    if (!isAvailable) return null;

    final userMessageObj = _buildVisionUserMessage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      userProfile: userProfile,
      productName: productName,
      productCategory: productCategory,
      applicationType: applicationType,
    );

    final payload = {
      'model': _visionModel,
      'messages': [
        {'role': 'system', 'content': _buildSystemPrompt()},
        {'role': 'user', 'content': userMessageObj},
      ],
      'temperature': 0.1,
      'top_p': 0.95,
      'max_tokens': 4096,
      // Note: We don't force json_object on Vision if NVIDIA doesn't support it for Vision 
      // but we will try. If it crashes, we'll remove it.
      'response_format': {'type': 'json_object'},
    };

    final text = await _callNvidia(payload);
    if (text == null) return null;

    final json = _extractJson(text);
    return GeminiAnalysisResult.fromJson(json);
  }

  // ─────────────────────────────────────────────────────────────
  // NVIDIA API Call with Retry
  // ─────────────────────────────────────────────────────────────

  /// Send a payload to NVIDIA NIM and return the assistant's text response.
  /// Retries up to 3 times on 429 (rate limit) errors with exponential backoff.
  static Future<String?> _callNvidia(Map<String, dynamic> payload) async {
    const maxRetries = 3;
    final payloadJson = jsonEncode(payload);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: payloadJson,
      );

      if (response.statusCode == 429) {
        if (attempt < maxRetries - 1) {
          final delaySec = 2 * (1 << attempt); // 2s, 4s
          debugPrint(
              'NVIDIA rate limit (429). Retrying in \${delaySec}s (attempt \${attempt + 1})...');
          await Future.delayed(Duration(seconds: delaySec));
          continue;
        }
        throw Exception(
          'Rate limit exceeded (429). Please wait a moment and try again.',
        );
      }

      if (response.statusCode != 200) {
        debugPrint(
            'NVIDIA API Error: \${response.statusCode} - \${response.body}');
        throw Exception('API Error: \${response.statusCode}');
      }

      final jsonRes = jsonDecode(response.body);
      final text =
          jsonRes['choices']?[0]?['message']?['content'] as String?;

      if (text == null || text.trim().isEmpty) {
        debugPrint('NVIDIA returned empty response');
        return null;
      }

      return text.trim();
    }

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // JSON Extraction
  // ─────────────────────────────────────────────────────────────

  /// Robustly extracts a JSON object from an LLM response that may contain
  /// markdown code fences, XML preamble, or other non-JSON text wrapping.
  static Map<String, dynamic> _extractJson(String raw) {
    var text = raw.trim();

    // 1. Strip markdown code fences
    text = text
        .replaceFirst(RegExp(r'^```(?:json)?\s*', multiLine: true), '')
        .replaceFirst(RegExp(r'```\s*$', multiLine: true), '')
        .trim();

    // 2. Try direct parse first (fast path when response_format works)
    try {
      final result = jsonDecode(text);
      if (result is Map<String, dynamic>) return result;
    } catch (_) {
      // Fall through to extraction logic
    }

    // 3. Locate the first '{' and its matching '}' via brace counting
    final startIdx = text.indexOf('{');
    if (startIdx == -1) {
      debugPrint(
          'AI response contained no JSON object. Raw:\n\${text.substring(0, text.length.clamp(0, 500))}');
      throw FormatException(
        'The AI did not return a valid analysis. '
        'Please try again with a clearer photo.',
      );
    }

    int depth = 0;
    int endIdx = -1;
    bool inString = false;
    bool escaped = false;

    for (int i = startIdx; i < text.length; i++) {
      final ch = text[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == r'\' && inString) {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (ch == '{') depth++;
      if (ch == '}') {
        depth--;
        if (depth == 0) {
          endIdx = i;
          break;
        }
      }
    }

    if (endIdx == -1) {
      debugPrint(
          'AI response had unbalanced braces. Raw:\n\${text.substring(0, text.length.clamp(0, 500))}');
      throw FormatException(
        'The AI returned an incomplete response. '
        'Please try again.',
      );
    }

    final jsonStr = text.substring(startIdx, endIdx + 1);
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      debugPrint(
          'JSON parse failed after extraction. Fragment:\n\${jsonStr.substring(0, jsonStr.length.clamp(0, 500))}');
      throw FormatException(
        'The AI response could not be parsed. '
        'Please try again with a clearer photo.',
      );
    }
  }

  // ─── Layer 1: System Prompt ─────────────────────────────────

  static String _buildSystemPrompt() {
    return '''You are CosmoSafe's Regulatory Intelligence Engine. You are a specialist combining cosmetic toxicology, INCI chemistry, and multi-jurisdiction regulatory analysis. Your ONLY job is to analyze cosmetic ingredient lists and return a safety assessment as valid JSON — nothing else.

════════════════════════════════════════
CRITICAL OUTPUT RULE — READ FIRST
════════════════════════════════════════
You MUST respond with ONLY a valid JSON object.
Do NOT write any text before the JSON.
Do NOT write any text after the JSON.
Do NOT wrap JSON in markdown code blocks or backticks.
Do NOT add explanations, summaries, or notes outside the JSON.
Your entire response must be parseable by json.loads() directly.

════════════════════════════════════════
WHAT YOU DO WITH THE INPUT
════════════════════════════════════════
You will receive either:
  (A) A product image → First extract the full ingredient list from the image label. Then analyze every extracted ingredient.
  (B) Raw OCR text → Parse and clean the ingredient list. Then analyze every ingredient.

In both cases, your final output is the same JSON structure.

════════════════════════════════════════
REGULATORY KNOWLEDGE BASE
════════════════════════════════════════
You reason across three regulatory layers. Apply them in this priority order for Indian users:

TIER 1 — INDIA (Primary, highest weight):
  Framework: Cosmetics Rules 2020 under Drugs & Cosmetics Act 1940
  Schedule S: Prohibited substances list
  Key bans: mercury compounds, lead compounds, arsenic compounds, hexachlorophene >1% in non-soap products, formaldehyde >0.2% in oral hygiene products, hydroquinone >2% in skin-lightening products
  Colorants: Schedule Q (BIS IS:4707 Part 1) — only listed colorants permitted
  Heavy metal limits: Arsenic ≤3 ppm, Lead ≤20 ppm, Mercury ≤1 ppm, Cadmium ≤5 ppm
  CDSCO topical steroid ban: clobetasol, betamethasone, mometasone, fluticasone are BANNED as cosmetic ingredients
  Preservative rules: parabens permitted with individual limits (methylparaben ≤0.4%, propylparaben ≤0.14%)

TIER 2 — EU (Secondary benchmark):
  Framework: Regulation (EC) No. 1223/2009
  Annex II: ~1,700 prohibited substances
  Annex III: ~380 restricted substances with concentration limits per product category
  Annex IV: Approved colorants only
  Annex V: Approved preservatives with maximum concentrations
  Annex VI: Approved UV filters with maximum concentrations
  CMR substances (Category 1A, 1B): Prohibited under Article 15
  CMR substances (Category 2): Restricted
  Fragrance allergens: 26 must be labeled if concentration >0.001% (rinse-off) or >0.01% (leave-on)

TIER 3 — USA (Tertiary benchmark):
  Framework: 21 CFR Parts 700–740 (FDA Cosmetics)
  Color additives: 21 CFR Parts 73, 74, 82
  Mercury Rule: 21 CFR 700.13
  Prohibited list: hexachlorophene, bithionol, chlorofluorocarbon propellants, halogenated salicylanilides, zirconium in aerosols, vinyl chloride in aerosols, methylene chloride, chloroform

════════════════════════════════════════
ANTI-HALLUCINATION RULES — MANDATORY
════════════════════════════════════════
RULE 1: Never fabricate or approximate regulatory citations. If you cannot confirm an ingredient's presence in a specific Annex, Schedule, or CFR section, set regulation_source to "UNVERIFIED" and confidence to "LOW".

RULE 2: Never generate CAS numbers from memory unless you are 100% certain. If uncertain, output null for cas_number.

RULE 3: If an ingredient uses a trade name, abbreviation, or shorthand you cannot resolve to a standard INCI name, output "UNRESOLVED" for inci_name and set flag_for_human_review to true. Do not guess.

RULE 4: When an ingredient is well-established and safe (Aqua, Glycerin, Niacinamide, Allantoin, Panthenol), state safety clearly with confidence "HIGH". Do not invent phantom concerns.

RULE 5: Every concern you flag must have a nameable regulatory basis. If you cannot name it, set inferred to true and reduce confidence.

RULE 6: Never invent usage frequency limits. Only cite limits based on known toxicological thresholds. If no data exists, output null for per_day, per_week, per_month.

════════════════════════════════════════
RATING SCALE (Assign one to the whole product)
════════════════════════════════════════
A — EXCELLENT: All ingredients safe and well-studied. No restricted substances. No concerns for this user's profile.
B — GOOD: Mostly safe with 1–2 minor concerns (mild preservatives, low-level potential irritants). No banned substances.
C — CAUTION: Contains restricted, concentration-dependent, or moderately concerning ingredients (certain parabens, formaldehyde releasers, undisclosed synthetic fragrances). Usable with awareness.
D — POOR: Multiple concerning ingredients or one ingredient with significant restriction in 2+ jurisdictions. Recommend alternatives.
E — AVOID: Contains at least one ingredient banned under CDSCO India, or banned in both EU and FDA, or a confirmed carcinogen or endocrine disruptor. Do not use.

════════════════════════════════════════
FLAG COLOR RULES (Assign one per ingredient)
════════════════════════════════════════
RED: Banned in any jurisdiction, restricted at typical use concentrations, known carcinogen, CMR 1A/1B, or matches the user's declared allergy
YELLOW: Restricted but conditionally allowed, potential irritant, concentration-dependent risk, CMR Category 2, or skin-type specific concern
GREEN: Safe, well-studied, no regulatory concerns in any of the three jurisdictions
GREY: Insufficient data, ingredient unresolved, or confidence is LOW/UNKNOWN

════════════════════════════════════════
PERSONALIZATION RULES
════════════════════════════════════════
Apply these overrides based on the user profile provided:

SKIN_TYPE = DRY: Flag alcohol denat, salicylic acid >1%, SLS as YELLOW even if not globally restricted
SKIN_TYPE = OILY: Flag heavy occlusives (petrolatum, mineral oil in face products) as YELLOW
SKIN_TYPE = SENSITIVE: Upgrade any synthetic fragrance, essential oils, methylisothiazolinone to RED minimum; all other preservatives to YELLOW minimum
SKIN_TYPE = ACNE_PRONE: Flag comedogenic ingredients (coconut oil, isopropyl myristate, lanolin, cocoa butter) as YELLOW
SKIN_TYPE = COMBINATION: Apply both DRY and OILY rules

ALLERGIES: Any ingredient matching the user's declared allergy list → override to RED, set allergy_match: true regardless of any other safety status

AGE < 3 or STATUS = PREGNANT or STATUS = BREASTFEEDING: Escalate all parabens, retinol, retinyl palmitate, salicylic acid, and synthetic musks to RED

════════════════════════════════════════
PROCESSING ORDER
════════════════════════════════════════
Step 1: Extract or receive ingredient list
Step 2: Normalize each ingredient to INCI name
Step 3: Apply regulatory analysis across all three tiers per ingredient
Step 4: Apply personalization overrides
Step 5: Compute per-ingredient flag_color
Step 6: Compute overall product grade (A–E) from the worst flags and their count
Step 7: Compute usage_guidance for the product as a whole
Step 8: Output ONLY the JSON object matching the schema below

════════════════════════════════════════
REQUIRED JSON OUTPUT SCHEMA
════════════════════════════════════════
Return exactly this structure. No additional keys. No missing keys.

{
  "product_summary": {
    "product_name": "string",
    "category": "string",
    "overall_flag": "GREEN",
    "one_line_verdict": "string"
  },
  "product_rating": {
    "grade": "A",
    "score": 85,
    "grade_reason": "string"
  },
  "ingredients": [
    {
      "raw_name": "string",
      "inci_name": "string",
      "cas_number": "string or null",
      "function": "string",
      "flag_color": "RED",
      "allergy_match": false,
      "flag_for_human_review": false,
      "confidence": "HIGH",
      "concerns": [
        {
          "concern_type": "NONE",
          "description": "string",
          "severity": "NONE",
          "regulation_source": "string",
          "inferred": false
        }
      ],
      "regulation_status": {
        "india_cdsco": "PERMITTED",
        "eu_1223_2009": "PERMITTED",
        "us_fda": "PERMITTED"
      }
    }
  ],
  "usage_guidance": {
    "per_day": null,
    "per_week": null,
    "per_month": null,
    "recommended_application": "string",
    "avoid_conditions": ["string"],
    "notes": "string"
  },
  "personalized_recommendation": {
    "suitable_for_user": true,
    "reason": "string",
    "safer_alternative_needed": false,
    "top_concerns_for_user": ["string"]
  },
  "meta": {
    "total_ingredients": 0,
    "red_count": 0,
    "yellow_count": 0,
    "green_count": 0,
    "grey_count": 0,
    "unresolved_count": 0,
    "extraction_method": "OCR_TEXT",
    "analysis_tier": "LLM_FULL"
  }
}

Sort the ingredients array: RED first, then YELLOW, then GREEN, then GREY.
''';
  }

  // ─── Layer 2: User Message ──────────────────────────────────

  static String _buildUserMessage({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? productCategory,
    String? applicationType,
  }) {
    final allergiesStr = userProfile.allergies.isEmpty
        ? 'NONE'
        : userProfile.allergies.join(', ');

    return '''Analyze these cosmetic ingredients for safety based strictly on the system instructions.

PRODUCT: \${productName ?? 'UNKNOWN'} | CATEGORY: \${productCategory ?? 'OTHER'} | TYPE: \${applicationType ?? 'leave_on'} | COUNTRY: India
USER: \${userProfile.name.isNotEmpty ? userProfile.name : 'User'} | AGE: \${userProfile.approximateAge} | SKIN: \${userProfile.skinType.promptLabel} | ALLERGIES: $allergiesStr | CONDITIONS: \${userProfile.condition.promptLabel} | USAGE: \${userProfile.usageFrequency.promptLabel}

INGREDIENTS:
$ingredientsText''';
  }

  static List<Map<String, dynamic>> _buildVisionUserMessage({
    required Uint8List imageBytes,
    required String mimeType,
    required UserProfile userProfile,
    String? productName,
    String? productCategory,
    String? applicationType,
  }) {
    final category = productCategory ?? 'OTHER';
    final appType = applicationType ?? 'leave_on';
    final name = productName ?? 'UNKNOWN';
    final allergiesStr = userProfile.allergies.isEmpty
        ? 'NONE'
        : userProfile.allergies.join(', ');

    final base64Image = base64Encode(imageBytes);

    return [
      {
        "type": "image_url",
        "image_url": {
          "url": "data:$mimeType;base64,$base64Image"
        }
      },
      {
        "type": "text",
        "text": '''
TASK: Analyze this cosmetic product label image for CosmoSafe.

STEP 1 — EXTRACT: Read the ingredient list from the product label in the image. The ingredients are usually on the back of the packaging, labeled "Ingredients:" or "Ingr:". Extract all ingredients exactly as printed.

STEP 2 — ANALYZE: Perform a full regulatory and safety analysis on every extracted ingredient using the rules in your system instructions.

PRODUCT CONTEXT:
- Name: $name
- Category: $category
- Application type: $appType
- Country of sale: India

USER PROFILE:
- Name: ${userProfile.name.isNotEmpty ? userProfile.name : 'User'}
- Age: ${userProfile.approximateAge}
- Skin type: ${userProfile.skinType.promptLabel}
- Declared allergies: ${allergiesStr.isEmpty ? "NONE" : allergiesStr}
- Health status: ${userProfile.condition.promptLabel.isEmpty ? "NONE" : userProfile.condition.promptLabel}
- Intended usage frequency: ${userProfile.usageFrequency.promptLabel}

Set extraction_method to "IMAGE_VISION" in your output meta.
Return ONLY the JSON object. No other text.
'''
      }
    ];
  }
}