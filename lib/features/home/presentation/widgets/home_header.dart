import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../auth/auth.dart';

class HomeHeader extends StatelessWidget {
  final int tiendasAbiertas;

  const HomeHeader({super.key, this.tiendasAbiertas = 0});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final nombre = context.select<AuthCubit, String>(
      (cubit) => cubit.state.maybeMap(
        authenticated: (s) => s.user.nombre?.split(' ').first ?? 'Usuario',
        orElse: () => 'Usuario',
      ),
    );

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
                    Icon(Icons.location_on, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      tiendasAbiertas > 0
                          ? '$tiendasAbiertas tiendas abiertas ahora'
                          : 'Pinar del Río',
                      style: AppTextStyles.bodySmall,
                    ),
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
