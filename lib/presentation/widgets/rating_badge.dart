import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../data/models/scan_analysis_result.dart';

/// Animated circular rating badge (A–E).
class RatingBadge extends StatelessWidget {
  final SafetyRating rating;
  final double score;
  final double size;

  const RatingBadge({
    super.key,
    required this.rating,
    required this.score,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 10,
      percent: (score / 100).clamp(0, 1),
      animation: true,
      animationDuration: 1200,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: rating.color,
      backgroundColor: rating.color.withValues(alpha: 0.15),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.code,
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: rating.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rating.label,
            style: TextStyle(
              fontSize: size * 0.09,
              fontWeight: FontWeight.w600,
              color: rating.color.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${score.toStringAsFixed(0)}/100',
            style: TextStyle(
              fontSize: size * 0.08,
              fontWeight: FontWeight.w500,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }
}
