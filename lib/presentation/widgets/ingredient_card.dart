import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/gemini_analysis_result.dart';
import '../../data/models/scan_analysis_result.dart';

/// Color-coded ingredient card with multi-jurisdiction regulatory data.
class IngredientCard extends StatefulWidget {
  final IngredientFinding finding;
  final int index;

  const IngredientCard({
    super.key,
    required this.finding,
    this.index = 0,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final f = widget.finding;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? f.severityColor.withValues(alpha: 0.12)
              : f.severityBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: f.severityColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header row ──────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: f.severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      f.severityIcon,
                      color: f.severityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (f.inciName != null && f.inciName != f.name) ...[
                          const SizedBox(height: 1),
                          Text(
                            f.inciName!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.55),
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _FlagChip(
                              label: f.severityLabel,
                              color: f.severityColor,
                            ),
                            if (f.ingredientFunction != null &&
                                f.ingredientFunction!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _FlagChip(
                                label: f.ingredientFunction!,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF6B7280),
                                filled: false,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badges column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (f.allergyMatch || f.isAllergen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_rounded,
                                  size: 12, color: Color(0xFFEF4444)),
                              const SizedBox(width: 3),
                              Text(
                                f.allergyMatch ? 'YOUR ALLERGY' : 'Allergen',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEF4444),
                                  letterSpacing: f.allergyMatch ? 0.3 : 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Confidence dot
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: switch (f.confidence) {
                                ConfidenceLevel.high =>
                                  const Color(0xFF10B981),
                                ConfidenceLevel.medium =>
                                  const Color(0xFFF59E0B),
                                ConfidenceLevel.low =>
                                  const Color(0xFFEF4444),
                                ConfidenceLevel.unknown =>
                                  const Color(0xFF6B7280),
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            f.confidence.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ─── Reason ──────────────────────────
              Text(
                f.reason,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.5,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.85),
                    ),
                maxLines: _expanded ? null : 2,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),

              // ─── Regulation status badges ────────
              if (f.regulationStatus != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _RegBadge(
                        flag: '🇮🇳',
                        status: f.regulationStatus!.indiaCdsco),
                    const SizedBox(width: 6),
                    _RegBadge(
                        flag: '🇪🇺',
                        status: f.regulationStatus!.eu12232009),
                    const SizedBox(width: 6),
                    _RegBadge(
                        flag: '🇺🇸', status: f.regulationStatus!.usFda),
                  ],
                ),
              ],

              // ─── Expanded content ────────────────
              if (_expanded) ...[
                // CAS Number
                if (f.casNumber != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.tag_rounded,
                          size: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Text(
                        'CAS: ${f.casNumber}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                      ),
                    ],
                  ),
                ],

                // Concerns list
                if (f.concerns.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: f.concerns.map((c) {
                      final chipColor = switch (c.severity) {
                        'HIGH' => const Color(0xFFEF4444),
                        'MEDIUM' => const Color(0xFFF59E0B),
                        'LOW' => const Color(0xFF3B82F6),
                        _ => const Color(0xFF6B7280),
                      };
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: chipColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: chipColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          c.concernType.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: chipColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Regulatory reference
                if (f.regulatoryRef != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.policy_rounded,
                          size: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f.regulatoryRef!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.55),
                              ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Max concentration
                if (f.maxAllowedConcentration != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.science_rounded,
                          size: 14,
                          color:
                              f.severityColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(
                        'Max allowed: ${f.maxAllowedConcentration}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: f.severityColor
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],

                // Skin-type warnings
                if (f.skinTypeWarnings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: f.skinTypeWarnings.map((w) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w,
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

                // Human review flag
                if (f.flagForHumanReview) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6)
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rate_review_rounded,
                            size: 14, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 6),
                        Text(
                          'Flagged for expert review',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // Expand indicator
              if (f.hasGeminiData || f.concerns.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 80 * widget.index),
        )
        .slideX(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 80 * widget.index),
          curve: Curves.easeOut,
        );
  }
}

// ─── Flag Chip ───────────────────────────────────────────────────
class _FlagChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _FlagChip({
    required this.label,
    required this.color,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: filled
            ? null
            : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Regulation Status Badge ─────────────────────────────────────
class _RegBadge extends StatelessWidget {
  final String flag;
  final RegStatus status;

  const _RegBadge({required this.flag, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RegStatus.banned => const Color(0xFFEF4444),
      RegStatus.restricted => const Color(0xFFF59E0B),
      RegStatus.permitted => const Color(0xFF10B981),
      RegStatus.noData => const Color(0xFF6B7280),
    };

    final statusLabel = switch (status) {
      RegStatus.banned => 'BAN',
      RegStatus.restricted => 'RST',
      RegStatus.permitted => 'OK',
      RegStatus.noData => '—',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
