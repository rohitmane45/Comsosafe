import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../data/database/ingredient_database.dart';
import '../../data/models/user_profile.dart';
import '../widgets/allergen_chip.dart';
import '../widgets/skin_type_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late SkinType _skinType;
  late List<String> _allergies;
  late int _ageRange;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameCtrl = TextEditingController(text: profile.name);
    _skinType = profile.skinType;
    _allergies = List.from(profile.allergies);
    _ageRange = profile.ageRange;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ProfileProvider>();
    await provider.updateProfile(UserProfile(
      name: _nameCtrl.text.trim(),
      skinType: _skinType,
      allergies: _allergies,
      ageRange: _ageRange,
      onboardingComplete: true,
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF10B981),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      setState(() => _hasChanges = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF162D22)]
                : [const Color(0xFFF7F4EE), const Color(0xFFF4F8F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Name ──────────────────────
                    _SectionHeader(
                      icon: Icons.person_rounded,
                      title: 'Name',
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Your name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      onChanged: (_) =>
                          setState(() => _hasChanges = true),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // ─── Skin Type ─────────────────
                    _SectionHeader(
                      icon: Icons.face_rounded,
                      title: 'Skin Type',
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SkinTypeSelector(
                        selected: _skinType,
                        onSelected: (t) {
                          setState(() {
                            _skinType = t;
                            _hasChanges = true;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── Age Range ─────────────────
                    _SectionHeader(
                      icon: Icons.cake_rounded,
                      title: 'Age Range',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [0, 1, 2, 3].map((range) {
                        final labels = [
                          'Under 18',
                          '18 – 30',
                          '30 – 45',
                          '45+'
                        ];
                        final isSelected = _ageRange == range;
                        return ChoiceChip(
                          label: Text(
                            labels[range],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _ageRange = range;
                              _hasChanges = true;
                            });
                          },
                          selectedColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 28),

                    // ─── Allergies ─────────────────
                    _SectionHeader(
                      icon: Icons.warning_amber_rounded,
                      title: 'Known Allergies',
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select substances you\'re allergic to. These will be flagged during ingredient analysis.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.55),
                          ),
                    ),
                    const SizedBox(height: 12),
                    AllergenChipSelector(
                      availableAllergens:
                          IngredientDatabase.commonAllergenNames,
                      selectedAllergens: _allergies,
                      onChanged: (a) {
                        setState(() {
                          _allergies = a;
                          _hasChanges = true;
                        });
                      },
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 32),

                    // ─── Save button ──────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _hasChanges ? _save : null,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          _hasChanges ? 'Save Changes' : 'No Changes',
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
        ),
      ],
    );
  }
}
