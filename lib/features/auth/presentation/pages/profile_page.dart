import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.maybeMap(
          authenticated: (s) => s.user,
          orElse: () => null,
        );
    final nombre = user?.nombre ?? user?.email.split('@').first ?? 'Usuario';
    final email = user?.email ?? '';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Mi Perfil'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ProfileHeader(inicial: inicial, nombre: nombre, email: email),
          const SizedBox(height: 24),
          ProfileSectionCard(
            title: 'Mi Actividad',
            items: [
              ProfileTile(
                icon: Icons.favorite_outline,
                label: 'Mis Favoritos',
                onTap: null,
              ),
              ProfileTile(
                icon: Icons.bookmark_outline,
                label: 'Productos Guardados',
                onTap: null,
              ),
              ProfileTile(
                icon: Icons.history,
                label: 'Historial de Búsqueda',
                onTap: null,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'Preferencias',
            items: [
              ProfileTile(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: null,
              ),
              ProfileTile(
                icon: Icons.notifications_outlined,
                label: 'Configurar Notificaciones',
                onTap: null,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            items: [
              ProfileTile(
                icon: Icons.logout,
                label: 'Cerrar Sesión',
                iconColor: AppColors.error,
                labelColor: AppColors.error,
                showChevron: false,
                showDivider: false,
                onTap: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Pinar Cerca v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
