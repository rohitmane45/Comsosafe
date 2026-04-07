// Full data model matching the CosmoSafe Regulatory Intelligence Engine
// JSON output schema (3-layer prompt architecture).
//
// Parses the structured JSON response from Gemini into strongly-typed Dart.

// ─── Enums ──────────────────────────────────────────────────────

enum FlagColor { red, yellow, green, grey }

extension FlagColorX on FlagColor {
  String get label => switch (this) {
    FlagColor.red => 'RED',
    FlagColor.yellow => 'YELLOW',
    FlagColor.green => 'GREEN',
    FlagColor.grey => 'GREY',
  };

  static FlagColor fromString(String value) {
    switch (value.toUpperCase().trim()) {
      case 'RED':
        return FlagColor.red;
      case 'YELLOW':
        return FlagColor.yellow;
      case 'GREEN':
        return FlagColor.green;
      default:
        return FlagColor.grey;
    }
  }
}

enum ConcernType {
  banned,
  restricted,
  allergen,
  comedogenic,
  irritant,
  endocrineDisruptor,
  cmr,
  heavyMetal,
  carcinogen,
  concentrationDependent,
  skinTypeSpecific,
  none,
}

extension ConcernTypeX on ConcernType {
  String get label => switch (this) {
    ConcernType.banned => 'BANNED',
    ConcernType.restricted => 'RESTRICTED',
    ConcernType.allergen => 'ALLERGEN',
    ConcernType.comedogenic => 'COMEDOGENIC',
    ConcernType.irritant => 'IRRITANT',
    ConcernType.endocrineDisruptor => 'ENDOCRINE DISRUPTOR',
    ConcernType.cmr => 'CMR',
    ConcernType.heavyMetal => 'HEAVY METAL',
    ConcernType.carcinogen => 'CARCINOGEN',
    ConcernType.concentrationDependent => 'CONCENTRATION DEPENDENT',
    ConcernType.skinTypeSpecific => 'SKIN TYPE SPECIFIC',
    ConcernType.none => 'NONE',
  };

  static ConcernType fromString(String value) {
    switch (value.toUpperCase().replaceAll(' ', '_').trim()) {
      case 'BANNED':
        return ConcernType.banned;
      case 'RESTRICTED':
        return ConcernType.restricted;
      case 'ALLERGEN':
        return ConcernType.allergen;
      case 'COMEDOGENIC':
        return ConcernType.comedogenic;
      case 'IRRITANT':
        return ConcernType.irritant;
      case 'ENDOCRINE_DISRUPTOR':
        return ConcernType.endocrineDisruptor;
      case 'CMR':
        return ConcernType.cmr;
      case 'HEAVY_METAL':
        return ConcernType.heavyMetal;
      case 'CARCINOGEN':
        return ConcernType.carcinogen;
      case 'CONCENTRATION_DEPENDENT':
        return ConcernType.concentrationDependent;
      case 'SKIN_TYPE_SPECIFIC':
        return ConcernType.skinTypeSpecific;
      default:
        return ConcernType.none;
    }
  }
}

enum ConfidenceLevel { high, medium, low, unknown }

extension ConfidenceLevelX on ConfidenceLevel {
  String get label => switch (this) {
    ConfidenceLevel.high => 'HIGH',
    ConfidenceLevel.medium => 'MEDIUM',
    ConfidenceLevel.low => 'LOW',
    ConfidenceLevel.unknown => 'UNKNOWN',
  };

  static ConfidenceLevel fromString(String value) {
    switch (value.toUpperCase().trim()) {
      case 'HIGH':
        return ConfidenceLevel.high;
      case 'MEDIUM':
        return ConfidenceLevel.medium;
      case 'LOW':
        return ConfidenceLevel.low;
      default:
        return ConfidenceLevel.unknown;
    }
  }
}

enum RegStatus { banned, restricted, permitted, noData }

extension RegStatusX on RegStatus {
  String get label => switch (this) {
    RegStatus.banned => 'BANNED',
    RegStatus.restricted => 'RESTRICTED',
    RegStatus.permitted => 'PERMITTED',
    RegStatus.noData => 'NO DATA',
  };

  static RegStatus fromString(String value) {
    switch (value.toUpperCase().replaceAll(' ', '_').trim()) {
      case 'BANNED':
        return RegStatus.banned;
      case 'RESTRICTED':
        return RegStatus.restricted;
      case 'PERMITTED':
        return RegStatus.permitted;
      default:
        return RegStatus.noData;
    }
  }
}

enum AnalysisTier { dbHit, llmFull, llmPartial }

extension AnalysisTierX on AnalysisTier {
  String get label => switch (this) {
    AnalysisTier.dbHit => 'DB_HIT',
    AnalysisTier.llmFull => 'LLM_FULL',
    AnalysisTier.llmPartial => 'LLM_PARTIAL',
  };

  static AnalysisTier fromString(String value) {
    switch (value.toUpperCase().replaceAll(' ', '_').trim()) {
      case 'DB_HIT':
        return AnalysisTier.dbHit;
      case 'LLM_FULL':
        return AnalysisTier.llmFull;
      default:
        return AnalysisTier.llmPartial;
    }
  }
}

// ─── Data Classes ───────────────────────────────────────────────

class ProductSummary {
  final String productName;
  final String category;
  final FlagColor overallFlag;
  final String oneLineVerdict;

  const ProductSummary({
    required this.productName,
    required this.category,
    required this.overallFlag,
    required this.oneLineVerdict,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      productName: (json['product_name'] ?? 'Unknown Product').toString(),
      category: (json['category'] ?? '').toString(),
      overallFlag:
          FlagColorX.fromString((json['overall_flag'] ?? 'GREY').toString()),
      oneLineVerdict: (json['one_line_verdict'] ?? '').toString(),
    );
  }
}

class ProductRating {
  final String grade; // A–E
  final int score; // 0–100
  final String gradeReason;

  const ProductRating({
    required this.grade,
    required this.score,
    required this.gradeReason,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      grade: (json['grade'] ?? 'C').toString(),
      score: (json['score'] as num?)?.toInt() ?? 50,
      gradeReason: (json['grade_reason'] ?? '').toString(),
    );
  }
}

class IngredientConcern {
  final ConcernType concernType;
  final String description;
  final String severity; // HIGH, MEDIUM, LOW, NONE
  final String regulationSource;
  final bool inferred;

  const IngredientConcern({
    required this.concernType,
    required this.description,
    required this.severity,
    required this.regulationSource,
    required this.inferred,
  });

  factory IngredientConcern.fromJson(Map<String, dynamic> json) {
    return IngredientConcern(
      concernType: ConcernTypeX.fromString(
          (json['concern_type'] ?? 'NONE').toString()),
      description: (json['description'] ?? '').toString(),
      severity: (json['severity'] ?? 'NONE').toString().toUpperCase(),
      regulationSource: (json['regulation_source'] ?? '').toString(),
      inferred: json['inferred'] == true,
    );
  }
}

class RegulationStatus {
  final RegStatus indiaCdsco;
  final RegStatus eu12232009;
  final RegStatus usFda;

  const RegulationStatus({
    required this.indiaCdsco,
    required this.eu12232009,
    required this.usFda,
  });

  factory RegulationStatus.fromJson(Map<String, dynamic> json) {
    return RegulationStatus(
      indiaCdsco:
          RegStatusX.fromString((json['india_cdsco'] ?? 'NO_DATA').toString()),
      eu12232009: RegStatusX.fromString(
          (json['eu_1223_2009'] ?? 'NO_DATA').toString()),
      usFda: RegStatusX.fromString((json['us_fda'] ?? 'NO_DATA').toString()),
    );
  }
}

class GeminiIngredient {
  final String rawName;
  final String inciName;
  final String? casNumber;
  final String function;
  final FlagColor flagColor;
  final bool allergyMatch;
  final bool flagForHumanReview;
  final ConfidenceLevel confidence;
  final List<IngredientConcern> concerns;
  final RegulationStatus regulationStatus;

  const GeminiIngredient({
    required this.rawName,
    required this.inciName,
    this.casNumber,
    required this.function,
    required this.flagColor,
    required this.allergyMatch,
    required this.flagForHumanReview,
    required this.confidence,
    required this.concerns,
    required this.regulationStatus,
  });

  factory GeminiIngredient.fromJson(Map<String, dynamic> json) {
    return GeminiIngredient(
      rawName: (json['raw_name'] ?? '').toString(),
      inciName: (json['inci_name'] ?? '').toString(),
      casNumber: json['cas_number']?.toString(),
      function: (json['function'] ?? '').toString(),
      flagColor:
          FlagColorX.fromString((json['flag_color'] ?? 'GREY').toString()),
      allergyMatch: json['allergy_match'] == true,
      flagForHumanReview: json['flag_for_human_review'] == true,
      confidence: ConfidenceLevelX.fromString(
          (json['confidence'] ?? 'UNKNOWN').toString()),
      concerns: (json['concerns'] as List<dynamic>?)
              ?.map((c) =>
                  IngredientConcern.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      regulationStatus: json['regulation_status'] != null
          ? RegulationStatus.fromJson(
              json['regulation_status'] as Map<String, dynamic>)
          : const RegulationStatus(
              indiaCdsco: RegStatus.noData,
              eu12232009: RegStatus.noData,
              usFda: RegStatus.noData,
            ),
    );
  }
}

class UsageGuidance {
  final int? perDay;
  final int? perWeek;
  final int? perMonth;
  final String recommendedApplication;
  final List<String> avoidConditions;
  final String notes;

  const UsageGuidance({
    this.perDay,
    this.perWeek,
    this.perMonth,
    required this.recommendedApplication,
    this.avoidConditions = const [],
    this.notes = '',
  });

  factory UsageGuidance.fromJson(Map<String, dynamic> json) {
    return UsageGuidance(
      perDay: (json['per_day'] as num?)?.toInt(),
      perWeek: (json['per_week'] as num?)?.toInt(),
      perMonth: (json['per_month'] as num?)?.toInt(),
      recommendedApplication:
          (json['recommended_application'] ?? '').toString(),
      avoidConditions: (json['avoid_conditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      notes: (json['notes'] ?? '').toString(),
    );
  }

  /// Build a human-readable usage recommendation string.
  String toReadableString() {
    final buf = StringBuffer();

    if (recommendedApplication.isNotEmpty) {
      buf.writeln(recommendedApplication);
    }

    if (perDay != null) {
      buf.writeln('📅 Max $perDay application${perDay! > 1 ? 's' : ''}/day');
    }
    if (perWeek != null) {
      buf.writeln(
          '📅 Max $perWeek application${perWeek! > 1 ? 's' : ''}/week');
    }
    if (perMonth != null) {
      buf.writeln(
          '📅 Max $perMonth application${perMonth! > 1 ? 's' : ''}/month');
    }

    if (avoidConditions.isNotEmpty) {
      buf.writeln('\n⚠️ Avoid if: ${avoidConditions.join(', ')}');
    }

    if (notes.isNotEmpty) {
      buf.writeln('\n💡 $notes');
    }

    return buf.toString().trim();
  }
}

class PersonalizedRecommendation {
  final bool suitableForUser;
  final String reason;
  final bool saferAlternativeNeeded;
  final List<String> topConcernsForUser;

  const PersonalizedRecommendation({
    required this.suitableForUser,
    required this.reason,
    required this.saferAlternativeNeeded,
    this.topConcernsForUser = const [],
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) {
    return PersonalizedRecommendation(
      suitableForUser: json['suitable_for_user'] == true,
      reason: (json['reason'] ?? '').toString(),
      saferAlternativeNeeded: json['safer_alternative_needed'] == true,
      topConcernsForUser: (json['top_concerns_for_user'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class AnalysisMeta {
  final int totalIngredients;
  final int redCount;
  final int yellowCount;
  final int greenCount;
  final int greyCount;
  final int unresolvedCount;
  final AnalysisTier analysisTier;

  const AnalysisMeta({
    required this.totalIngredients,
    required this.redCount,
    required this.yellowCount,
    required this.greenCount,
    required this.greyCount,
    required this.unresolvedCount,
    required this.analysisTier,
  });

  factory AnalysisMeta.fromJson(Map<String, dynamic> json) {
    return AnalysisMeta(
      totalIngredients: (json['total_ingredients'] as num?)?.toInt() ?? 0,
      redCount: (json['red_count'] as num?)?.toInt() ?? 0,
      yellowCount: (json['yellow_count'] as num?)?.toInt() ?? 0,
      greenCount: (json['green_count'] as num?)?.toInt() ?? 0,
      greyCount: (json['grey_count'] as num?)?.toInt() ?? 0,
      unresolvedCount: (json['unresolved_count'] as num?)?.toInt() ?? 0,
      analysisTier: AnalysisTierX.fromString(
          (json['analysis_tier'] ?? 'LLM_FULL').toString()),
    );
  }
}

// ─── Root Model ─────────────────────────────────────────────────

class GeminiAnalysisResult {
  final ProductSummary productSummary;
  final ProductRating productRating;
  final List<GeminiIngredient> ingredients;
  final UsageGuidance usageGuidance;
  final PersonalizedRecommendation personalizedRecommendation;
  final AnalysisMeta meta;

  const GeminiAnalysisResult({
    required this.productSummary,
    required this.productRating,
    required this.ingredients,
    required this.usageGuidance,
    required this.personalizedRecommendation,
    required this.meta,
  });

  factory GeminiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return GeminiAnalysisResult(
      productSummary: ProductSummary.fromJson(
          json['product_summary'] as Map<String, dynamic>? ?? {}),
      productRating: ProductRating.fromJson(
          json['product_rating'] as Map<String, dynamic>? ?? {}),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((i) =>
                  GeminiIngredient.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      usageGuidance: UsageGuidance.fromJson(
          json['usage_guidance'] as Map<String, dynamic>? ?? {}),
      personalizedRecommendation: PersonalizedRecommendation.fromJson(
          json['personalized_recommendation'] as Map<String, dynamic>? ??
              {}),
      meta: AnalysisMeta.fromJson(
          json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}
