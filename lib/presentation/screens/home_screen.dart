import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../data/models/user_profile.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF162D22),
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1160 : 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ─── Header ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CosmoSafe',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.5,
                                    ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(
                                      begin: -0.2,
                                      end: 0,
                                      duration: 500.ms),
                              const SizedBox(height: 4),
                              Text(
                                profile.name.isNotEmpty
                                    ? 'Hey ${profile.name} 👋'
                                    : 'Your cosmetic safety companion',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 400.ms, delay: 200.ms),
                            ],
                          ),
                        ),
                        // Profile avatar
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => const ProfileScreen()),
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                profile.skinType.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
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
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ─── Skin type badge ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981)
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              profile.skinType.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${profile.skinType.label} Skin',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  profile.allergies.isEmpty
                                      ? 'No allergens set'
                                      : '${profile.allergies.length} allergen${profile.allergies.length == 1 ? '' : 's'} tracked',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.55),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const ProfileScreen()),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 300.ms),

                    const SizedBox(height: 28),

                    // ─── Main content ────────────────────
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _HeroCard(isDark: isDark)),
                          const SizedBox(width: 20),
                          Expanded(child: _FeatureCard(isDark: isDark)),
                        ],
                      )
                    else ...[
                      _HeroCard(isDark: isDark),
                      const SizedBox(height: 20),
                      _FeatureCard(isDark: isDark),
                    ],

                    const SizedBox(height: 20),

                    // ─── Rating legend ────────────────────
                    _RatingLegend(isDark: isDark),
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

// ─── Hero Card ───────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool isDark;
  const _HeroCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scan & Analyze\nIngredients',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Point your camera at the back label or upload a photo. Get instant safety ratings from A to E based on Indian cosmetic standards.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const ScanScreen()),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Start Analysis'),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 400.ms);
  }
}

// ─── Feature Card ────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final bool isDark;
  const _FeatureCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = <_FeatureItem>[
      _FeatureItem(
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFF10B981),
        title: 'Camera + Upload',
        desc: 'Capture via camera on mobile, or upload on any platform.',
      ),
      _FeatureItem(
        icon: Icons.shield_rounded,
        color: const Color(0xFFF59E0B),
        title: 'Indian Compliance',
        desc: 'Checked against IS 4707, Schedule Q & CDSCO standards.',
      ),
      _FeatureItem(
        icon: Icons.palette_rounded,
        color: const Color(0xFFEF4444),
        title: 'Color-coded Results',
        desc: '🔴 Harmful  🟡 Caution  🟢 Safe — at a glance.',
      ),
      _FeatureItem(
        icon: Icons.person_rounded,
        color: const Color(0xFF8B5CF6),
        title: 'Personalized',
        desc: 'Tailored to your skin type, allergies & age.',
      ),
    ];

    return Card(
      color: isDark ? const Color(0xFF111827) : const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < items.length; i++) ...[
              _FeatureRow(item: items[i], index: i),
              if (i < items.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 500.ms);
  }
}

class _FeatureItem {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

class _FeatureRow extends StatelessWidget {
  final _FeatureItem item;
  final int index;
  const _FeatureRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(item.icon, color: item.color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.desc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
            duration: 350.ms,
            delay: Duration(milliseconds: 600 + (index * 100)))
        .slideX(
            begin: 0.15,
            end: 0,
            duration: 350.ms,
            delay: Duration(milliseconds: 600 + (index * 100)));
  }
}

// ─── Rating Legend ───────────────────────────────────────────
class _RatingLegend extends StatelessWidget {
  final bool isDark;
  const _RatingLegend({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final ratings = [
      ('A', 'Excellent', const Color(0xFF10B981)),
      ('B', 'Good', const Color(0xFF34D399)),
      ('C', 'Average', const Color(0xFFF59E0B)),
      ('D', 'Below Avg', const Color(0xFFF97316)),
      ('E', 'Avoid', const Color(0xFFEF4444)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Rating Scale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: ratings.map((r) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: r.$3.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            r.$1,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: r.$3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.$2,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 700.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 700.ms);
  }
}
