import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user_profile.dart';

/// Persists and exposes the user's skin profile.
class ProfileProvider extends ChangeNotifier {
  static const _storageKey = 'cosmosafe_user_profile';

  UserProfile _profile = const UserProfile();
  bool _loaded = false;

  UserProfile get profile => _profile;
  bool get loaded => _loaded;
  bool get onboardingComplete => _profile.onboardingComplete;
  SkinType get skinType => _profile.skinType;

  /// Load profile from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        _profile = UserProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        // corrupted — reset
        _profile = const UserProfile();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  /// Persist changes.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profile.toJson()));
  }

  Future<void> updateName(String name) async {
    _profile = _profile.copyWith(name: name);
    await _save();
    notifyListeners();
  }

  Future<void> updateSkinType(SkinType type) async {
    _profile = _profile.copyWith(skinType: type);
    await _save();
    notifyListeners();
  }

  Future<void> updateAllergies(List<String> allergies) async {
    _profile = _profile.copyWith(allergies: allergies);
    await _save();
    notifyListeners();
  }

  Future<void> updateAgeRange(int range) async {
    _profile = _profile.copyWith(ageRange: range);
    await _save();
    notifyListeners();
  }

  Future<void> updateCondition(DeclaredCondition condition) async {
    _profile = _profile.copyWith(condition: condition);
    await _save();
    notifyListeners();
  }

  Future<void> updateUsageFrequency(UsageFrequency frequency) async {
    _profile = _profile.copyWith(usageFrequency: frequency);
    await _save();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _profile = _profile.copyWith(onboardingComplete: true);
    await _save();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _save();
    notifyListeners();
  }
}
