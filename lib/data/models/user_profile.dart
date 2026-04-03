/// Skin types supported by the app.
enum SkinType { oily, dry, combination, sensitive, normal }

extension SkinTypeX on SkinType {
  String get label => switch (this) {
    SkinType.oily => 'Oily',
    SkinType.dry => 'Dry',
    SkinType.combination => 'Combination',
    SkinType.sensitive => 'Sensitive',
    SkinType.normal => 'Normal',
  };

  String get description => switch (this) {
    SkinType.oily => 'Excess sebum, shiny T-zone, enlarged pores',
    SkinType.dry => 'Tight feeling, flaky patches, dull appearance',
    SkinType.combination => 'Oily T-zone with dry cheeks',
    SkinType.sensitive => 'Easily irritated, redness, reactive to products',
    SkinType.normal => 'Balanced moisture, minimal issues',
  };

  String get emoji => switch (this) {
    SkinType.oily => '💧',
    SkinType.dry => '🏜️',
    SkinType.combination => '⚖️',
    SkinType.sensitive => '🌸',
    SkinType.normal => '✨',
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
      default:
        return SkinType.normal;
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

  const UserProfile({
    this.name = '',
    this.skinType = SkinType.normal,
    this.allergies = const [],
    this.ageRange = 1,
    this.onboardingComplete = false,
  });

  UserProfile copyWith({
    String? name,
    SkinType? skinType,
    List<String>? allergies,
    int? ageRange,
    bool? onboardingComplete,
  }) {
    return UserProfile(
      name: name ?? this.name,
      skinType: skinType ?? this.skinType,
      allergies: allergies ?? this.allergies,
      ageRange: ageRange ?? this.ageRange,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  String get ageRangeLabel => switch (ageRange) {
    0 => 'Under 18',
    1 => '18 – 30',
    2 => '30 – 45',
    _ => '45+',
  };

  Map<String, dynamic> toJson() => {
    'name': name,
    'skinType': skinType.name,
    'allergies': allergies,
    'ageRange': ageRange,
    'onboardingComplete': onboardingComplete,
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
    );
  }
}
