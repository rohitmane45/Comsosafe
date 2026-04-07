import '../../data/database/ingredient_database.dart';
import '../../data/database/ingredient_matcher.dart';
import '../../data/models/gemini_analysis_result.dart';
import '../../data/models/scan_analysis_result.dart';
import '../../data/models/user_profile.dart';
import 'gemini_service.dart';

/// On-device ingredient analysis engine with Gemini AI fallback.
///
/// Primary: Gemini AI for deep multi-jurisdiction regulatory analysis.
/// Fallback: Local IS 4707 database matching when offline.
class AnalysisEngine {
  AnalysisEngine._();

  /// Analyze with Gemini first, fall back to local DB if unavailable.
  static Future<ScanAnalysisResult> analyzeWithFallback({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? brand,
    String? productCategory,
    String? applicationType,
  }) async {
    // Try Gemini first
    if (GeminiService.isAvailable) {
      try {
        final geminiResult = await GeminiService.analyze(
          ingredientsText: ingredientsText,
          userProfile: userProfile,
          productName: productName,
          productCategory: productCategory,
          applicationType: applicationType,
        );

        if (geminiResult != null) {
          return ScanAnalysisResult.fromGemini(
            gemini: geminiResult,
            ingredientsText: ingredientsText,
          );
        }
      } catch (e) {
        // Gemini failed (bad JSON, network error, etc.) — fall through to
        // offline analysis instead of crashing.
        // ignore: avoid_print
        print('Gemini AI analysis failed, falling back to offline: $e');
      }
    }

    // Fallback to local analysis
    return analyzeOffline(
      ingredientsText: ingredientsText,
      userProfile: userProfile,
      productName: productName,
      brand: brand,
      productCategory: productCategory,
    );
  }

  /// Local-only analysis using IS 4707 database.
  static ScanAnalysisResult analyzeOffline({
    required String ingredientsText,
    required UserProfile userProfile,
    String? productName,
    String? brand,
    String? productCategory,
  }) {
    // 1. Match ingredients against database
    final matches = IngredientMatcher.matchAll(ingredientsText);

    // 2. Build findings list
    final findings = <IngredientFinding>[];
    int harmfulCount = 0;
    int cautionCount = 0;
    int safeCount = 0;

    for (final match in matches) {
      final entry = match.entry;
      final skinWarnings = <String>[];

      // Check if this ingredient is bad for the user's skin type
      if (entry.badForSkinTypes.contains(userProfile.skinType.name)) {
        skinWarnings
            .add('Not recommended for ${userProfile.skinType.label} skin');
      }

      final flagColor = switch (entry.severity) {
        'harmful' => FlagColor.red,
        'caution' => FlagColor.yellow,
        'safe' => FlagColor.green,
        _ => FlagColor.grey,
      };

      findings.add(IngredientFinding(
        name: entry.name,
        severity: entry.severity,
        reason: entry.reason,
        regulatoryRef: entry.regulatoryRef,
        skinTypeWarnings: skinWarnings,
        isAllergen: entry.isAllergen,
        maxAllowedConcentration: entry.maxConcentrationPercent,
        matchConfidence: match.confidence,
        flagColor: flagColor,
        confidence: match.confidence >= 0.9
            ? ConfidenceLevel.high
            : match.confidence >= 0.7
                ? ConfidenceLevel.medium
                : ConfidenceLevel.low,
      ));

      switch (entry.severity) {
        case 'harmful':
          harmfulCount++;
        case 'caution':
          cautionCount++;
        case 'safe':
          safeCount++;
      }
    }

    // Sort: harmful first, then caution, then safe
    findings.sort((a, b) {
      const order = {
        FlagColor.red: 0,
        FlagColor.yellow: 1,
        FlagColor.green: 2,
        FlagColor.grey: 3,
      };
      return (order[a.flagColor] ?? 3).compareTo(order[b.flagColor] ?? 3);
    });

    // 3. Calculate score
    double score = 100.0;

    for (final match in matches) {
      final entry = match.entry;

      switch (entry.severity) {
        case 'harmful':
          score -= 25;
        case 'caution':
          score -= 8;
      }

      // Extra penalty if ingredient is bad for user's skin type
      if (entry.badForSkinTypes.contains(userProfile.skinType.name)) {
        score -= 5;
      }

      // Extra penalty if ingredient matches user's declared allergies
      if (_isUserAllergen(entry, userProfile.allergies)) {
        score -= 15;
      }
    }

    score = score.clamp(0, 100);

    // 4. Build allergen warnings
    final allergenWarnings = <String>[];
    for (final match in matches) {
      if (match.entry.isAllergen) {
        allergenWarnings.add('${match.entry.name} is a known allergen');
      }
      if (_isUserAllergen(match.entry, userProfile.allergies)) {
        allergenWarnings
            .add('⚠️ ${match.entry.name} matches your declared allergy!');
      }
    }

    // 5. Build skin-type warnings
    final skinTypeWarnings = <String>[];
    for (final match in matches) {
      if (match.entry.badForSkinTypes.contains(userProfile.skinType.name)) {
        skinTypeWarnings.add(
            '${match.entry.name} may not be ideal for ${userProfile.skinType.label} skin');
      }
    }

    // 6. Determine rating
    final rating = SafetyRatingX.fromScore(score);

    // 7. Generate summary
    final summary = _buildSummary(
      rating: rating,
      harmfulCount: harmfulCount,
      cautionCount: cautionCount,
      safeCount: safeCount,
      totalMatched: matches.length,
      skinType: userProfile.skinType,
      allergenWarnings: allergenWarnings,
    );

    // 8. Generate usage recommendation
    final usage = _buildUsageRecommendation(
      rating: rating,
      skinType: userProfile.skinType,
      productCategory: productCategory,
      harmfulCount: harmfulCount,
    );

    return ScanAnalysisResult(
      productName: productName,
      brand: brand,
      productCategory: productCategory,
      ingredientsText: ingredientsText,
      rating: rating,
      score: score,
      summary: summary,
      usageRecommendation: usage,
      findings: findings,
      allergenWarnings: allergenWarnings,
      skinTypeWarnings: skinTypeWarnings,
      totalIngredientsFound: matches.length,
      harmfulCount: harmfulCount,
      cautionCount: cautionCount,
      safeCount: safeCount,
      analyzedAt: DateTime.now(),
      isGeminiAnalysis: false,
    );
  }

  /// Check if a DB entry matches any of the user's declared allergies.
  static bool _isUserAllergen(
      IngredientEntry entry, List<String> userAllergies) {
    if (userAllergies.isEmpty) return false;

    final entryNameLower = entry.name.toLowerCase();
    final allNamesLower = [
      entryNameLower,
      ...entry.aliases.map((a) => a.toLowerCase())
    ];

    for (final allergy in userAllergies) {
      final allergyLower = allergy.toLowerCase();
      for (final name in allNamesLower) {
        if (name.contains(allergyLower) || allergyLower.contains(name)) {
          return true;
        }
      }
      // Also check common groupings
      if (allergyLower.contains('paraben') &&
          entryNameLower.contains('paraben')) {
        return true;
      }
      if (allergyLower.contains('sulfate') &&
          (entryNameLower.contains('sulfate') ||
              entryNameLower.contains('sulphate'))) {
        return true;
      }
      if (allergyLower.contains('formaldehyde') &&
          (entryNameLower.contains('formaldehyde') ||
              entryNameLower.contains('dmdm') ||
              entryNameLower.contains('quaternium') ||
              entryNameLower.contains('imidazolidinyl') ||
              entryNameLower.contains('diazolidinyl') ||
              entryNameLower.contains('bronopol'))) {
        return true;
      }
    }
    return false;
  }

  static String _buildSummary({
    required SafetyRating rating,
    required int harmfulCount,
    required int cautionCount,
    required int safeCount,
    required int totalMatched,
    required SkinType skinType,
    required List<String> allergenWarnings,
  }) {
    final buf = StringBuffer();

    if (totalMatched == 0) {
      return 'No recognized ingredients were found in the scanned text. '
          'Try capturing a clearer image of the ingredient list.';
    }

    buf.write(
        'Analyzed $totalMatched ingredient${totalMatched > 1 ? 's' : ''}. ');

    if (harmfulCount > 0) {
      buf.write(
          '🔴 $harmfulCount prohibited/harmful substance${harmfulCount > 1 ? 's' : ''} detected per Indian cosmetic regulations (IS 4707). ');
    }
    if (cautionCount > 0) {
      buf.write(
          '🟡 $cautionCount ingredient${cautionCount > 1 ? 's' : ''} require${cautionCount == 1 ? 's' : ''} caution (restricted or known irritants). ');
    }
    if (safeCount > 0) {
      buf.write(
          '🟢 $safeCount ingredient${safeCount > 1 ? 's' : ''} recognized as safe. ');
    }

    if (allergenWarnings.isNotEmpty) {
      buf.write(
          '\n\n⚠️ ${allergenWarnings.length} allergen alert${allergenWarnings.length > 1 ? 's' : ''} for your profile. ');
    }

    return buf.toString().trim();
  }

  static String _buildUsageRecommendation({
    required SafetyRating rating,
    required SkinType skinType,
    String? productCategory,
    required int harmfulCount,
  }) {
    final category = (productCategory ?? '').toLowerCase();
    final isRinseOff = <String>{
      'cleanser',
      'face wash',
      'body wash',
      'shampoo',
      'soap',
      'scrub',
    }.any((c) => category.contains(c));

    final buf = StringBuffer();

    // Rating-based base recommendation
    switch (rating) {
      case SafetyRating.a:
        buf.write(isRinseOff
            ? 'Safe for daily use as directed.'
            : 'Safe for daily use. Follow label instructions.');
      case SafetyRating.b:
        buf.write(isRinseOff
            ? 'Generally safe for daily use. Rinse thoroughly.'
            : 'Generally safe for daily use.');
      case SafetyRating.c:
        buf.write(isRinseOff
            ? 'Use daily only if skin tolerates it. Otherwise 3-4 times per week.'
            : 'Use every other day or 3-4 times per week.');
      case SafetyRating.d:
        buf.write(isRinseOff
            ? 'Use sparingly. Avoid long contact. Limit to a few times per week.'
            : 'Limit to 1-2 times per week. Avoid daily use.');
      case SafetyRating.e:
        buf.write('Not recommended. Consider a safer alternative.');
    }

    // Skin-type specific addition
    buf.write('\n\n');
    switch (skinType) {
      case SkinType.oily:
        buf.write(
            '💧 For oily skin: Look for non-comedogenic, oil-free formulas. Avoid heavy occlusives like mineral oil.');
      case SkinType.dry:
        buf.write(
            '🏜️ For dry skin: Ensure the product has humectants (glycerin, hyaluronic acid). Avoid alcohol denat and harsh sulfates.');
      case SkinType.combination:
        buf.write(
            '⚖️ For combination skin: Apply heavier products only on dry areas. Keep T-zone light.');
      case SkinType.sensitive:
        buf.write(
            '🌸 For sensitive skin: Patch test on inner wrist 24h before full use. Avoid fragrances and strong preservatives.');
      case SkinType.normal:
        buf.write(
            '✨ For normal skin: This product should work well. Maintain your routine and stay hydrated.');
      case SkinType.acneProne:
        buf.write(
            '🔬 For acne-prone skin: Avoid comedogenic ingredients. Look for non-comedogenic labels and salicylic acid/niacinamide products.');
    }

    if (harmfulCount > 0) {
      buf.write(
          '\n\n🚨 This product contains ingredients banned or restricted under Indian cosmetic regulations. '
          'Consider discontinuing use and consulting a dermatologist.');
    }

    return buf.toString();
  }
}
