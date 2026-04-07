/// Skin types supported by the app.
enum SkinType { oily, dry, combination, sensitive, normal, acneProne }

extension SkinTypeX on SkinType {
  String get label => switch (this) {
    SkinType.oily => 'Oily',
    SkinType.dry => 'Dry',
    SkinType.combination => 'Combination',
    SkinType.sensitive => 'Sensitive',
    SkinType.normal => 'Normal',
    SkinType.acneProne => 'Acne Prone',
  };

  String get promptLabel => switch (this) {
    SkinType.oily => 'OILY',
    SkinType.dry => 'DRY',
    SkinType.combination => 'COMBINATION',
    SkinType.sensitive => 'SENSITIVE',
    SkinType.normal => 'NORMAL',
    SkinType.acneProne => 'ACNE_PRONE',
  };

  String get description => switch (this) {
    SkinType.oily => 'Excess sebum, shiny T-zone, enlarged pores',
    SkinType.dry => 'Tight feeling, flaky patches, dull appearance',
    SkinType.combination => 'Oily T-zone with dry cheeks',
    SkinType.sensitive => 'Easily irritated, redness, reactive to products',
    SkinType.normal => 'Balanced moisture, minimal issues',
    SkinType.acneProne => 'Frequent breakouts, clogged pores, blackheads',
  };

  String get emoji => switch (this) {
    SkinType.oily => '💧',
    SkinType.dry => '🏜️',
    SkinType.combination => '⚖️',
    SkinType.sensitive => '🌸',
    SkinType.normal => '✨',
    SkinType.acneProne => '🔬',
  };

  static SkinType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'oily':
        return SkinType.oily;
      case 'dry':
        return SkinType.dry;
      case 'combination':
        return SkinType.combination;
      case 'sensitive':
        return SkinType.sensitive;
      case 'acneprone':
      case 'acne_prone':
        return SkinType.acneProne;
      default:
        return SkinType.normal;
    }
  }
}

/// Declared medical/health conditions that affect ingredient safety.
enum DeclaredCondition { none, pregnant, breastfeeding }

extension DeclaredConditionX on DeclaredCondition {
  String get label => switch (this) {
    DeclaredCondition.none => 'None',
    DeclaredCondition.pregnant => 'Pregnant',
    DeclaredCondition.breastfeeding => 'Breastfeeding',
  };

  String get promptLabel => switch (this) {
    DeclaredCondition.none => 'NONE',
    DeclaredCondition.pregnant => 'PREGNANT',
    DeclaredCondition.breastfeeding => 'BREASTFEEDING',
  };

  String get emoji => switch (this) {
    DeclaredCondition.none => '✅',
    DeclaredCondition.pregnant => '🤰',
    DeclaredCondition.breastfeeding => '🤱',
  };

  static DeclaredCondition fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'pregnant':
        return DeclaredCondition.pregnant;
      case 'breastfeeding':
        return DeclaredCondition.breastfeeding;
      default:
        return DeclaredCondition.none;
    }
  }
}

/// Usage frequency intent for the product.
enum UsageFrequency { daily, fewTimesWeek, weekly, occasional }

extension UsageFrequencyX on UsageFrequency {
  String get label => switch (this) {
    UsageFrequency.daily => 'Daily',
    UsageFrequency.fewTimesWeek => 'Few times a week',
    UsageFrequency.weekly => 'Weekly',
    UsageFrequency.occasional => 'Occasionally',
  };

  String get promptLabel => switch (this) {
    UsageFrequency.daily => 'DAILY',
    UsageFrequency.fewTimesWeek => 'FEW_TIMES_WEEK',
    UsageFrequency.weekly => 'WEEKLY',
    UsageFrequency.occasional => 'OCCASIONAL',
  };

  static UsageFrequency fromString(String value) {
    switch (value.toUpperCase().trim()) {
      case 'DAILY':
        return UsageFrequency.daily;
      case 'FEW_TIMES_WEEK':
        return UsageFrequency.fewTimesWeek;
      case 'WEEKLY':
        return UsageFrequency.weekly;
      case 'OCCASIONAL':
        return UsageFrequency.occasional;
      default:
        return UsageFrequency.daily;
    }
  }
}

/// Represents a user's skin profile & allergy configuration.
class UserProfile {
  final String name;
  final SkinType skinType;
  final List<String> allergies;
  final int ageRange; // 0 = under-18, 1 = 18-30, 2 = 30-45, 3 = 45+
  final bool onboardingComplete;
  final DeclaredCondition condition;
  final UsageFrequency usageFrequency;

  const UserProfile({
    this.name = '',
    this.skinType = SkinType.normal,
    this.allergies = const [],
    this.ageRange = 1,
    this.onboardingComplete = false,
    this.condition = DeclaredCondition.none,
    this.usageFrequency = UsageFrequency.daily,
  });

  UserProfile copyWith({
    String? name,
    SkinType? skinType,
    List<String>? allergies,
    int? ageRange,
    bool? onboardingComplete,
    DeclaredCondition? condition,
    UsageFrequency? usageFrequency,
  }) {
    return UserProfile(
      name: name ?? this.name,
      skinType: skinType ?? this.skinType,
      allergies: allergies ?? this.allergies,
      ageRange: ageRange ?? this.ageRange,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      condition: condition ?? this.condition,
      usageFrequency: usageFrequency ?? this.usageFrequency,
    );
  }

  String get ageRangeLabel => switch (ageRange) {
    0 => 'Under 18',
    1 => '18 – 30',
    2 => '30 – 45',
    _ => '45+',
  };

  /// Approximate age for the Gemini prompt.
  int get approximateAge => switch (ageRange) {
    0 => 15,
    1 => 24,
    2 => 37,
    _ => 52,
  };

  Map<String, dynamic> toJson() => {
    'name': name,
    'skinType': skinType.name,
    'allergies': allergies,
    'ageRange': ageRange,
    'onboardingComplete': onboardingComplete,
    'condition': condition.name,
    'usageFrequency': usageFrequency.name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] ?? '').toString(),
      skinType: SkinTypeX.fromString((json['skinType'] ?? 'normal').toString()),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ageRange: (json['ageRange'] as int?) ?? 1,
      onboardingComplete: (json['onboardingComplete'] as bool?) ?? false,
      condition: DeclaredConditionX.fromString(
          (json['condition'] ?? 'none').toString()),
      usageFrequency: UsageFrequencyX.fromString(
          (json['usageFrequency'] ?? 'DAILY').toString()),
    );
  }
}
