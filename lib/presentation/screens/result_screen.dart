import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/scan_analysis_result.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/rating_badge.dart';

class ResultScreen extends StatelessWidget {
  final ScanAnalysisResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            tooltip: 'Back to Home',
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
                : [const Color(0xFFF7F4EE), const Color(0xFFFDFCF8)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Rating Card ─────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (result.productName != null)
                              Text(
                                result.productName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                            if (result.productName != null)
                              const SizedBox(height: 20),
                            RatingBadge(
                              rating: result.rating,
                              score: result.score,
                            ),
                            const SizedBox(height: 20),

                            // Stats row
                            Row(
                              children: [
                                _StatChip(
                                  label: 'Harmful',
                                  count: result.harmfulCount,
                                  color: const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 8),
                                _StatChip(
                                  label: 'Caution',
                                  count: result.cautionCount,
                                  color: const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 8),
                                _StatChip(
                                  label: 'Safe',
                                  count: result.safeCount,
                                  color: const Color(0xFF10B981),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms),

                    const SizedBox(height: 16),

                    // ─── Allergen Alert Banner ────────────
                    if (result.allergenWarnings.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_rounded,
                                    color: Color(0xFFEF4444), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Allergen Alerts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFEF4444),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...result.allergenWarnings.map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• $w',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .shake(
                            hz: 2,
                            duration: 500.ms,
                            delay: 600.ms,
                          ),

                    // ─── Summary Card ─────────────────────
                    _SectionCard(
                      icon: Icons.summarize_rounded,
                      title: 'Summary',
                      color: const Color(0xFF10B981),
                      child: Text(
                        result.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(
                            begin: 0.1,
                            end: 0,
                            duration: 400.ms,
                            delay: 200.ms),

                    const SizedBox(height: 16),

                    // ─── Usage Recommendation ─────────────
                    if (result.usageRecommendation != null)
                      _SectionCard(
                        icon: Icons.schedule_rounded,
                        title: 'Usage Recommendation',
                        color: const Color(0xFF8B5CF6),
                        child: Text(
                          result.usageRecommendation!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                  ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              delay: 300.ms),

                    if (result.usageRecommendation != null)
                      const SizedBox(height: 16),

                    // ─── Skin Type Warnings ───────────────
                    if (result.skinTypeWarnings.isNotEmpty) ...[
                      _SectionCard(
                        icon: Icons.face_rounded,
                        title: 'Skin Type Warnings',
                        color: const Color(0xFFF97316),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.skinTypeWarnings
                              .map(
                                (w) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('⚠️ ',
                                          style: TextStyle(fontSize: 14)),
                                      Expanded(
                                        child: Text(
                                          w,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms),
                      const SizedBox(height: 16),
                    ],

                    // ─── Ingredient Findings ──────────────
                    if (result.findings.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF173A2D)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.science_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF173A2D),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Ingredient Analysis (${result.findings.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 500.ms),

                      // Filter tabs
                      _FilterTabs(result: result),

                      const SizedBox(height: 12),

                      ...result.findings.asMap().entries.map(
                            (e) => IngredientCard(
                              finding: e.value,
                              index: e.key,
                            ),
                          ),
                    ],

                    // ─── Raw ingredients text ─────────────
                    if (result.ingredientsText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        icon: Icons.text_snippet_rounded,
                        title: 'Raw Ingredient Text',
                        color: const Color(0xFF6B7280),
                        child: Text(
                          result.ingredientsText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ─── Disclaimer ───────────────────────
                    Text(
                      'This analysis is informational only based on IS 4707 / BIS standards. It does not replace medical or dermatology advice.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.45),
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // ─── Action buttons ──────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Scan Again'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Home'),
                          ),
                        ),
                      ],
                    ),

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

// ─── Stat Chip ───────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Card ────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Filter Tabs ─────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final ScanAnalysisResult result;
  const _FilterTabs({required this.result});

  @override
  Widget build(BuildContext context) {
    final counts = [
      ('All', result.findings.length, const Color(0xFF6B7280)),
      ('🔴', result.harmfulCount, const Color(0xFFEF4444)),
      ('🟡', result.cautionCount, const Color(0xFFF59E0B)),
      ('🟢', result.safeCount, const Color(0xFF10B981)),
    ];

    return Row(
      children: counts.map((c) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: c.$3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${c.$1} ${c.$2}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.$3,
            ),
          ),
        );
      }).toList(),
    );
  }
}
