import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/user_profile.dart';

/// A visually rich skin-type selector with emoji cards.
class SkinTypeSelector extends StatelessWidget {
  final SkinType? selected;
  final ValueChanged<SkinType> onSelected;

  const SkinTypeSelector({
    super.key,
    this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: SkinType.values.asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        final isActive = selected == type;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => onSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF10B981).withValues(alpha: 0.1))
                  : (isDark
                      ? const Color(0xFF1F2937)
                      : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF10B981)
                    : (isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB)),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFF10B981)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.3,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                duration: 400.ms,
                delay: Duration(milliseconds: 100 * index),
              )
              .slideY(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                delay: Duration(milliseconds: 100 * index),
                curve: Curves.easeOut,
              ),
        );
      }).toList(),
    );
  }
}
