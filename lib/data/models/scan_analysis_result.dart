import 'package:flutter/material.dart';

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
    SafetyRating.c => 'Average',
    SafetyRating.d => 'Below Average',
    SafetyRating.e => 'Poor — Avoid',
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

/// Represents a single ingredient finding with severity color coding.
class IngredientFinding {
  final String name;
  final String severity; // 'harmful', 'caution', 'safe'
  final String reason;
  final String? regulatoryRef;
  final List<String> skinTypeWarnings;
  final bool isAllergen;
  final double? maxAllowedConcentration;
  final double matchConfidence;

  const IngredientFinding({
    required this.name,
    required this.severity,
    required this.reason,
    this.regulatoryRef,
    this.skinTypeWarnings = const [],
    this.isAllergen = false,
    this.maxAllowedConcentration,
    this.matchConfidence = 1.0,
  });

  Color get severityColor => switch (severity) {
    'harmful' => const Color(0xFFEF4444),
    'caution' => const Color(0xFFF59E0B),
    'safe' => const Color(0xFF10B981),
    _ => const Color(0xFF6B7280),
  };

  Color get severityBgColor => switch (severity) {
    'harmful' => const Color(0x1AEF4444),
    'caution' => const Color(0x1AF59E0B),
    'safe' => const Color(0x1A10B981),
    _ => const Color(0x1A6B7280),
  };

  IconData get severityIcon => switch (severity) {
    'harmful' => Icons.dangerous_rounded,
    'caution' => Icons.warning_amber_rounded,
    'safe' => Icons.check_circle_rounded,
    _ => Icons.info_outline_rounded,
  };

  String get severityLabel => switch (severity) {
    'harmful' => 'HARMFUL',
    'caution' => 'CAUTION',
    'safe' => 'SAFE',
    _ => 'UNKNOWN',
  };
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
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  bool get hasFindings => findings.isNotEmpty;
  String get ratingCode => rating.code;

  List<IngredientFinding> get harmfulFindings =>
      findings.where((f) => f.severity == 'harmful').toList();
  List<IngredientFinding> get cautionFindings =>
      findings.where((f) => f.severity == 'caution').toList();
  List<IngredientFinding> get safeFindings =>
      findings.where((f) => f.severity == 'safe').toList();
}

