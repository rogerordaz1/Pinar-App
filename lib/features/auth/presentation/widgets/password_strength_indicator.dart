import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int level;
  const PasswordStrengthIndicator({super.key, required this.level});

  Color _colorForIndex(int index) {
    if (level == 0) return AppColors.outlineVariant;
    if (index >= level) return AppColors.outlineVariant;
    if (level == 1) return AppColors.error;
    if (level == 2) return const Color(0xFFF9A825);
    return AppColors.primary;
  }

  String get _label {
    if (level == 0) return '';
    if (level == 1) return 'Débil';
    if (level == 2) return 'Media';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: _colorForIndex(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (_label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Seguridad: $_label',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}

class PasswordRequirementRow extends StatelessWidget {
  final bool met;
  final String text;
  const PasswordRequirementRow({super.key, required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: met ? AppColors.primary : AppColors.outlineVariant,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: met ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
