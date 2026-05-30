import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

class StatusBadge extends StatelessWidget {
  final bool abierto;
  const StatusBadge({super.key, required this.abierto});

  @override
  Widget build(BuildContext context) {
    final color = abierto ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            abierto ? 'Abierto ahora' : 'Cerrado',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
