import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/gemini_analysis_result.dart';
import '../../data/models/scan_analysis_result.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/rating_badge.dart';

class ResultScreen extends StatefulWidget {
  final ScanAnalysisResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _activeFilter = 'All';

  List<IngredientFinding> get _filteredFindings {
    switch (_activeFilter) {
      case 'RED':
        return widget.result.harmfulFindings;
      case 'YELLOW':
        return widget.result.cautionFindings;
      case 'GREEN':
        return widget.result.safeFindings;
      case 'GREY':
        return widget.result.unknownFindings;
      default:
        return widget.result.findings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        actions: [
          if (r.isGeminiAnalysis)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 14, color: Color(0xFF8B5CF6)),
                  SizedBox(width: 4),
                  Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ),
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
                    // ─── Verdict Banner ─────────────────
                    if (r.oneLineVerdict != null && r.oneLineVerdict!.isNotEmpty)
                      _VerdictBanner(
                        verdict: r.oneLineVerdict!,
                        flag: r.overallFlag ?? FlagColor.grey,
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -0.1, end: 0, duration: 500.ms),

                    if (r.oneLineVerdict != null) const SizedBox(height: 16),

                    // ─── Rating Card ─────────────────────
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            if (r.productName != null)
                              Text(
                                r.productName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                textAlign: TextAlign.center,
                              ),
                            if (r.productName != null)
                              const SizedBox(height: 20),
                            RatingBadge(
                              rating: r.rating,
                              score: r.score,
                            ),
                            const SizedBox(height: 16),

                            // Grade reason
                            if (r.gradeReason != null &&
                                r.gradeReason!.isNotEmpty)
                              Text(
                                r.gradeReason!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      height: 1.5,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                textAlign: TextAlign.center,
                              ),

                            const SizedBox(height: 20),

                            // Stats row
                            Row(
                              children: [
                                _StatChip(
                                  label: 'Harmful',
                                  count: r.harmfulCount,
                                  color: const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                _StatChip(
                                  label: 'Caution',
                                  count: r.cautionCount,
                                  color: const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 6),
                                _StatChip(
                                  label: 'Safe',
                                  count: r.safeCount,
                                  color: const Color(0xFF10B981),
                                ),
                                if (r.greyCount > 0) ...[
                                  const SizedBox(width: 6),
                                  _StatChip(
                                    label: 'Unknown',
                                    count: r.greyCount,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ],
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

                    // ─── Personalized Recommendation ─────
                    if (r.personalizedRecommendation != null)
                      _PersonalizedCard(rec: r.personalizedRecommendation!)
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 150.ms)
                          .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              delay: 150.ms),

                    if (r.personalizedRecommendation != null)
                      const SizedBox(height: 16),

                    // ─── Allergen Alert Banner ────────────
                    if (r.allergenWarnings.isNotEmpty)
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
                            ...r.allergenWarnings.map(
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
                          .shake(hz: 2, duration: 500.ms, delay: 600.ms),

                    // ─── Usage Guidance ───────────────────
                    if (r.usageRecommendation != null)
                      _SectionCard(
                        icon: Icons.schedule_rounded,
                        title: 'Usage Guidance',
                        color: const Color(0xFF8B5CF6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.usageRecommendation!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.6),
                            ),
                            if (r.usageGuidance != null &&
                                r.usageGuidance!.avoidConditions.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: r.usageGuidance!.avoidConditions
                                    .map((c) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '⚠️ $c',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 250.ms)
                          .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              delay: 250.ms),

                    if (r.usageRecommendation != null)
                      const SizedBox(height: 16),

                    // ─── Skin Type Warnings ───────────────
                    if (r.skinTypeWarnings.isNotEmpty) ...[
                      _SectionCard(
                        icon: Icons.face_rounded,
                        title: 'Skin Type Warnings',
                        color: const Color(0xFFF97316),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: r.skinTypeWarnings
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
                          .fadeIn(duration: 400.ms, delay: 350.ms),
                      const SizedBox(height: 16),
                    ],

                    // ─── Ingredient Findings ──────────────
                    if (r.findings.isNotEmpty) ...[
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
                              'Ingredient Analysis (${r.findings.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms),

                      // Filter tabs
                      _FilterTabs(
                        result: r,
                        active: _activeFilter,
                        onChanged: (f) =>
                            setState(() => _activeFilter = f),
                      ),

                      const SizedBox(height: 12),

                      ..._filteredFindings.asMap().entries.map(
                            (e) => IngredientCard(
                              finding: e.value,
                              index: e.key,
                            ),
                          ),
                    ],

                    // ─── Summary (offline mode) ──────────
                    if (!r.isGeminiAnalysis && r.summary.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionCard(
                        icon: Icons.summarize_rounded,
                        title: 'Summary',
                        color: const Color(0xFF10B981),
                        child: Text(
                          r.summary,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.6),
                        ),
                      ),
                    ],

                    // ─── Analysis tier badge ─────────────
                    if (r.analysisMeta != null) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1F2937)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.1) ??
                                  Colors.grey,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                r.isGeminiAnalysis
                                    ? Icons.auto_awesome_rounded
                                    : Icons.offline_bolt_rounded,
                                size: 14,
                                color: r.isGeminiAnalysis
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                r.isGeminiAnalysis
                                    ? 'AI Regulatory Analysis (${r.analysisMeta!.analysisTier.label})'
                                    : 'Offline Analysis (IS 4707)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ─── Disclaimer ───────────────────────
                    Text(
                      r.isGeminiAnalysis
                          ? 'This AI-powered analysis covers CDSCO India, EU Regulation 1223/2009, and US FDA frameworks. It is informational only and does not replace medical or dermatology advice.'
                          : 'This analysis is informational only based on IS 4707 / BIS standards. It does not replace medical or dermatology advice.',
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

// ─── Verdict Banner ──────────────────────────────────────────────
class _VerdictBanner extends StatelessWidget {
  final String verdict;
  final FlagColor flag;

  const _VerdictBanner({required this.verdict, required this.flag});

  @override
  Widget build(BuildContext context) {
    final color = switch (flag) {
      FlagColor.red => const Color(0xFFEF4444),
      FlagColor.yellow => const Color(0xFFF59E0B),
      FlagColor.green => const Color(0xFF10B981),
      FlagColor.grey => const Color(0xFF6B7280),
    };

    final icon = switch (flag) {
      FlagColor.red => Icons.dangerous_rounded,
      FlagColor.yellow => Icons.warning_amber_rounded,
      FlagColor.green => Icons.verified_rounded,
      FlagColor.grey => Icons.help_outline_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              verdict,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Personalized Recommendation Card ────────────────────────────
class _PersonalizedCard extends StatelessWidget {
  final PersonalizedRecommendation rec;
  const _PersonalizedCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final suitable = rec.suitableForUser;
    final color =
        suitable ? const Color(0xFF10B981) : const Color(0xFFF97316);

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
                  child: Icon(
                    suitable
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_down_alt_rounded,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  suitable
                      ? 'Suitable for You'
                      : 'Not Ideal for You',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                ),
                const Spacer(),
                if (rec.saferAlternativeNeeded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SEEK ALTERNATIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEF4444),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rec.reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.5,
                  ),
            ),
            if (rec.topConcernsForUser.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rec.topConcernsForUser.map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Stat Chip ───────────────────────────────────────────────────
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

// ─── Section Card ────────────────────────────────────────────────
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

// ─── Filter Tabs ─────────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final ScanAnalysisResult result;
  final String active;
  final ValueChanged<String> onChanged;

  const _FilterTabs({
    required this.result,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final counts = [
      ('All', result.findings.length, const Color(0xFF6B7280)),
      ('🔴', result.harmfulCount, const Color(0xFFEF4444)),
      ('🟡', result.cautionCount, const Color(0xFFF59E0B)),
      ('🟢', result.safeCount, const Color(0xFF10B981)),
      if (result.greyCount > 0)
        ('⚪', result.greyCount, const Color(0xFF6B7280)),
    ];

    final labels = ['All', 'RED', 'YELLOW', 'GREEN', if (result.greyCount > 0) 'GREY'];

    return Row(
      children: List.generate(counts.length, (i) {
        final c = counts[i];
        final isActive = labels[i] == active;
        return GestureDetector(
          onTap: () => onChanged(labels[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? c.$3.withValues(alpha: 0.2)
                  : c.$3.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: c.$3.withValues(alpha: 0.5))
                  : null,
            ),
            child: Text(
              '${c.$1} ${c.$2}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: c.$3,
              ),
            ),
          ),
        );
      }),
    );
  }
}
