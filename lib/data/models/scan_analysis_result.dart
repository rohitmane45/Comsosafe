import 'package:flutter/material.dart';

import 'gemini_analysis_result.dart';

enum SafetyRating { a, b, c, d, e }

extension SafetyRatingX on SafetyRating {
  String get code => switch (this) {
    SafetyRating.a => 'A',
    SafetyRating.b => 'B',
    SafetyRating.c => 'C',
    SafetyRating.d => 'D',
    SafetyRating.e => 'E',
  };

  String get label => switch (this) {
    SafetyRating.a => 'Excellent',
    SafetyRating.b => 'Good',
    SafetyRating.c => 'Caution',
    SafetyRating.d => 'Poor',
    SafetyRating.e => 'Avoid',
  };

  Color get color => switch (this) {
    SafetyRating.a => const Color(0xFF10B981),
    SafetyRating.b => const Color(0xFF34D399),
    SafetyRating.c => const Color(0xFFF59E0B),
    SafetyRating.d => const Color(0xFFF97316),
    SafetyRating.e => const Color(0xFFEF4444),
  };

  static SafetyRating fromCode(String value) {
    switch (value.trim().toUpperCase()) {
      case 'A':
        return SafetyRating.a;
      case 'B':
        return SafetyRating.b;
      case 'C':
        return SafetyRating.c;
      case 'D':
        return SafetyRating.d;
      case 'E':
        return SafetyRating.e;
      default:
        return SafetyRating.c;
    }
  }

  static SafetyRating fromScore(double score) {
    if (score >= 85) return SafetyRating.a;
    if (score >= 70) return SafetyRating.b;
    if (score >= 50) return SafetyRating.c;
    if (score >= 30) return SafetyRating.d;
    return SafetyRating.e;
  }
}

/// Represents a single ingredient finding with severity & regulatory data.
class IngredientFinding {
  final String name;
  final String severity; // 'harmful', 'caution', 'safe', 'unknown'
  final String reason;
  final String? regulatoryRef;
  final List<String> skinTypeWarnings;
  final bool isAllergen;
  final double? maxAllowedConcentration;
  final double matchConfidence;

  // ─── New Gemini-enriched fields ────
  final String? inciName;
  final String? casNumber;
  final String? ingredientFunction;
  final FlagColor flagColor;
  final ConfidenceLevel confidence;
  final List<IngredientConcern> concerns;
  final RegulationStatus? regulationStatus;
  final bool allergyMatch;
  final bool flagForHumanReview;

  const IngredientFinding({
    required this.name,
    required this.severity,
    required this.reason,
    this.regulatoryRef,
    this.skinTypeWarnings = const [],
    this.isAllergen = false,
    this.maxAllowedConcentration,
    this.matchConfidence = 1.0,
    // New fields with defaults
    this.inciName,
    this.casNumber,
    this.ingredientFunction,
    this.flagColor = FlagColor.grey,
    this.confidence = ConfidenceLevel.unknown,
    this.concerns = const [],
    this.regulationStatus,
    this.allergyMatch = false,
    this.flagForHumanReview = false,
  });

  /// Create from a Gemini ingredient result.
  factory IngredientFinding.fromGemini(GeminiIngredient gi) {
    // Map flag color to severity string
    final severity = switch (gi.flagColor) {
      FlagColor.red => 'harmful',
      FlagColor.yellow => 'caution',
      FlagColor.green => 'safe',
      FlagColor.grey => 'unknown',
    };

    // Build combined reason from concerns
    final reason = gi.concerns.isNotEmpty
        ? gi.concerns.map((c) => c.description).join('. ')
        : 'No concerns identified.';

    // Pick the most relevant regulatory ref
    String? regRef;
    for (final c in gi.concerns) {
      if (c.regulationSource.isNotEmpty &&
          c.regulationSource != 'UNVERIFIED') {
        regRef = c.regulationSource;
        break;
      }
    }

    return IngredientFinding(
      name: gi.rawName,
      severity: severity,
      reason: reason,
      regulatoryRef: regRef,
      isAllergen: gi.allergyMatch ||
          gi.concerns.any((c) => c.concernType == ConcernType.allergen),
      matchConfidence: switch (gi.confidence) {
        ConfidenceLevel.high => 1.0,
        ConfidenceLevel.medium => 0.75,
        ConfidenceLevel.low => 0.5,
        ConfidenceLevel.unknown => 0.3,
      },
      // Gemini-enriched fields
      inciName: gi.inciName != 'UNRESOLVED' ? gi.inciName : null,
      casNumber: gi.casNumber,
      ingredientFunction: gi.function,
      flagColor: gi.flagColor,
      confidence: gi.confidence,
      concerns: gi.concerns,
      regulationStatus: gi.regulationStatus,
      allergyMatch: gi.allergyMatch,
      flagForHumanReview: gi.flagForHumanReview,
    );
  }

  Color get severityColor => switch (flagColor) {
    FlagColor.red => const Color(0xFFEF4444),
    FlagColor.yellow => const Color(0xFFF59E0B),
    FlagColor.green => const Color(0xFF10B981),
    FlagColor.grey => const Color(0xFF6B7280),
  };

  Color get severityBgColor => switch (flagColor) {
    FlagColor.red => const Color(0x1AEF4444),
    FlagColor.yellow => const Color(0x1AF59E0B),
    FlagColor.green => const Color(0x1A10B981),
    FlagColor.grey => const Color(0x1A6B7280),
  };

  IconData get severityIcon => switch (flagColor) {
    FlagColor.red => Icons.dangerous_rounded,
    FlagColor.yellow => Icons.warning_amber_rounded,
    FlagColor.green => Icons.check_circle_rounded,
    FlagColor.grey => Icons.help_outline_rounded,
  };

  String get severityLabel => switch (flagColor) {
    FlagColor.red => 'HARMFUL',
    FlagColor.yellow => 'CAUTION',
    FlagColor.green => 'SAFE',
    FlagColor.grey => 'UNKNOWN',
  };

  String get flagEmoji => switch (flagColor) {
    FlagColor.red => '🔴',
    FlagColor.yellow => '🟡',
    FlagColor.green => '🟢',
    FlagColor.grey => '⚪',
  };

  /// Whether this finding has rich Gemini data.
  bool get hasGeminiData => inciName != null || concerns.isNotEmpty;
}

/// Full analysis result for a scanned product.
class ScanAnalysisResult {
  final String? productName;
  final String? brand;
  final String? productCategory;
  final String ingredientsText;
  final SafetyRating rating;
  final double score; // 0–100
  final String summary;
  final String? usageRecommendation;
  final List<IngredientFinding> findings;
  final List<String> allergenWarnings;
  final List<String> skinTypeWarnings;
  final int totalIngredientsFound;
  final int harmfulCount;
  final int cautionCount;
  final int safeCount;
  final DateTime analyzedAt;

  // ─── New Gemini-enriched fields ────
  final FlagColor? overallFlag;
  final String? oneLineVerdict;
  final String? gradeReason;
  final PersonalizedRecommendation? personalizedRecommendation;
  final UsageGuidance? usageGuidance;
  final AnalysisMeta? analysisMeta;
  final bool isGeminiAnalysis;

  ScanAnalysisResult({
    this.productName,
    this.brand,
    this.productCategory,
    required this.ingredientsText,
    required this.rating,
    required this.score,
    required this.summary,
    this.usageRecommendation,
    this.findings = const [],
    this.allergenWarnings = const [],
    this.skinTypeWarnings = const [],
    this.totalIngredientsFound = 0,
    this.harmfulCount = 0,
    this.cautionCount = 0,
    this.safeCount = 0,
    DateTime? analyzedAt,
    // New fields
    this.overallFlag,
    this.oneLineVerdict,
    this.gradeReason,
    this.personalizedRecommendation,
    this.usageGuidance,
    this.analysisMeta,
    this.isGeminiAnalysis = false,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  /// Create from a Gemini analysis result.
  factory ScanAnalysisResult.fromGemini({
    required GeminiAnalysisResult gemini,
    required String ingredientsText,
  }) {
    final findings =
        gemini.ingredients.map((gi) => IngredientFinding.fromGemini(gi)).toList();

    final rating = SafetyRatingX.fromCode(gemini.productRating.grade);

    // Build allergen warnings from findings
    final allergenWarnings = <String>[];
    for (final f in findings) {
      if (f.allergyMatch) {
        allergenWarnings.add('⚠️ ${f.name} matches your declared allergy!');
      }
      if (f.isAllergen && !f.allergyMatch) {
        allergenWarnings.add('${f.name} is a known allergen');
      }
    }

    return ScanAnalysisResult(
      productName: gemini.productSummary.productName != 'Unknown Product'
          ? gemini.productSummary.productName
          : null,
      productCategory: gemini.productSummary.category,
      ingredientsText: ingredientsText,
      rating: rating,
      score: gemini.productRating.score.toDouble(),
      summary: gemini.productRating.gradeReason,
      usageRecommendation: gemini.usageGuidance.toReadableString(),
      findings: findings,
      allergenWarnings: allergenWarnings,
      skinTypeWarnings: findings
          .where((f) => f.concerns.any(
              (c) => c.concernType == ConcernType.skinTypeSpecific))
          .map((f) => '${f.name}: skin-type specific concern')
          .toList(),
      totalIngredientsFound: gemini.meta.totalIngredients,
      harmfulCount: gemini.meta.redCount,
      cautionCount: gemini.meta.yellowCount,
      safeCount: gemini.meta.greenCount,
      // Gemini-enriched
      overallFlag: gemini.productSummary.overallFlag,
      oneLineVerdict: gemini.productSummary.oneLineVerdict,
      gradeReason: gemini.productRating.gradeReason,
      personalizedRecommendation: gemini.personalizedRecommendation,
      usageGuidance: gemini.usageGuidance,
      analysisMeta: gemini.meta,
      isGeminiAnalysis: true,
    );
  }

  bool get hasFindings => findings.isNotEmpty;
  String get ratingCode => rating.code;

  List<IngredientFinding> get harmfulFindings =>
      findings.where((f) => f.flagColor == FlagColor.red).toList();
  List<IngredientFinding> get cautionFindings =>
      findings.where((f) => f.flagColor == FlagColor.yellow).toList();
  List<IngredientFinding> get safeFindings =>
      findings.where((f) => f.flagColor == FlagColor.green).toList();
  List<IngredientFinding> get unknownFindings =>
      findings.where((f) => f.flagColor == FlagColor.grey).toList();

  int get greyCount => unknownFindings.length;
}
