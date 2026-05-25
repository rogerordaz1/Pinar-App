import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<AuthCubit, String>((cubit) {
      final state = cubit.state;
      if (state is AuthAuthenticated) {
        return state.user.nombre?.split(' ').first ?? 'Usuario';
      }
      return 'Usuario';
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $nombre',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Pinar del Río', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: null,
            tooltip: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}
