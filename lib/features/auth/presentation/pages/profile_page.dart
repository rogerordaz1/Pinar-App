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
          _ProfileHeader(inicial: inicial, nombre: nombre, email: email),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Mi Actividad',
            items: [
              _ProfileTile(
                icon: Icons.favorite_outline,
                label: 'Mis Favoritos',
                onTap: null,
              ),
              _ProfileTile(
                icon: Icons.bookmark_outline,
                label: 'Productos Guardados',
                onTap: null,
              ),
              _ProfileTile(
                icon: Icons.history,
                label: 'Historial de Búsqueda',
                onTap: null,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Preferencias',
            items: [
              _ProfileTile(
                icon: Icons.settings_outlined,
                label: 'Configuración',
                onTap: null,
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                label: 'Configurar Notificaciones',
                onTap: null,
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            items: [
              _ProfileTile(
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

class _ProfileHeader extends StatelessWidget {
  final String inicial;
  final String nombre;
  final String email;

  const _ProfileHeader({
    required this.inicial,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary,
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> items;

  const _SectionCard({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ],
        Material(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;
  final bool showDivider;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.onSurfaceVariant;
    final effectiveLabelColor = labelColor ?? AppColors.onSurface;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: effectiveIconColor, size: 22),
          title: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: effectiveLabelColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          trailing: showChevron
              ? Icon(Icons.chevron_right,
                  color: AppColors.onSurfaceVariant, size: 20)
              : null,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          minLeadingWidth: 24,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.outlineVariant.withOpacity(0.5),
          ),
      ],
    );
  }
}
