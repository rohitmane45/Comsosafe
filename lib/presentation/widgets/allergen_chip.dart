import 'package:flutter/material.dart';

/// Allergen chip selector — a filterable chip list for choosing allergens.
class AllergenChipSelector extends StatelessWidget {
  final List<String> availableAllergens;
  final List<String> selectedAllergens;
  final ValueChanged<List<String>> onChanged;

  const AllergenChipSelector({
    super.key,
    required this.availableAllergens,
    required this.selectedAllergens,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableAllergens.map((allergen) {
        final isSelected = selectedAllergens.contains(allergen);

        return FilterChip(
          label: Text(
            allergen,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<String>.from(selectedAllergens);
            if (selected) {
              updated.add(allergen);
            } else {
              updated.remove(allergen);
            }
            onChanged(updated);
          },
          selectedColor: const Color(0xFFEF4444),
          backgroundColor: isDark
              ? const Color(0xFF1F2937)
              : const Color(0xFFF3F4F6),
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFFEF4444)
                  : (isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFD1D5DB)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }
}
