import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../data/database/ingredient_database.dart';
import '../../data/models/user_profile.dart';
import '../widgets/allergen_chip.dart';
import '../widgets/skin_type_selector.dart';

/// First-launch onboarding: Welcome → Skin Type → Allergies.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  SkinType _selectedSkin = SkinType.normal;
  final List<String> _selectedAllergies = [];
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final provider = context.read<ProfileProvider>();
    await provider.updateProfile(UserProfile(
      name: _nameCtrl.text.trim(),
      skinType: _selectedSkin,
      allergies: _selectedAllergies,
      onboardingComplete: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1A2B23),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF7F4EE),
                    const Color(0xFFE8F4ED),
                    const Color(0xFFF9EFD9),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress dots
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final isActive = i <= _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 32 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF10B981)
                            : (isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  children: [
                    _WelcomePage(
                      nameCtrl: _nameCtrl,
                      onNext: _nextPage,
                    ),
                    _SkinTypePage(
                      selected: _selectedSkin,
                      onSelected: (t) => setState(() => _selectedSkin = t),
                      onNext: _nextPage,
                    ),
                    _AllergyPage(
                      selected: _selectedAllergies,
                      onChanged: (a) => setState(() {
                        _selectedAllergies
                          ..clear()
                          ..addAll(a);
                      }),
                      onFinish: _nextPage,
                    ),
                  ],
                ),
              ),

              // Skip button (only on first two pages)
              if (_currentPage < 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ─────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final TextEditingController nameCtrl;
  final VoidCallback onNext;

  const _WelcomePage({required this.nameCtrl, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Color(0xFF10B981),
              size: 48,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          Text(
            'Welcome to\nCosmoSafe',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Scan cosmetic ingredients and get safety ratings based on Indian compliance standards (IS 4707).',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.65),
                ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms),
          const SizedBox(height: 40),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Your name (optional)',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 600.ms),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Let\'s get started'),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 800.ms),
        ],
      ),
    );
  }
}

// ─── Page 2: Skin Type ────────────────────────────────────────
class _SkinTypePage extends StatelessWidget {
  final SkinType selected;
  final ValueChanged<SkinType> onSelected;
  final VoidCallback onNext;

  const _SkinTypePage({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What\'s your skin type?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize safety ratings and usage recommendations just for you.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 28),
          Center(
            child: SkinTypeSelector(
              selected: selected,
              onSelected: onSelected,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 3: Allergies ────────────────────────────────────────
class _AllergyPage extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final VoidCallback onFinish;

  const _AllergyPage({
    required this.selected,
    required this.onChanged,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Any known allergies?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select ingredients you\'re allergic to. We\'ll flag them during analysis. You can update this later.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          AllergenChipSelector(
            availableAllergens: IngredientDatabase.commonAllergenNames,
            selectedAllergens: selected,
            onChanged: onChanged,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onFinish,
              icon: const Icon(Icons.check_rounded),
              label: Text(
                selected.isEmpty
                    ? 'No allergies — finish setup'
                    : 'Save ${selected.length} allerg${selected.length == 1 ? 'y' : 'ies'} & finish',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
