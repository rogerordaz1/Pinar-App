import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class OrdenChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const OrdenChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.outlineVariant,
      ),
    );
  }
}
