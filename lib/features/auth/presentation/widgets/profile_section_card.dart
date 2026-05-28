import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class ProfileSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> items;

  const ProfileSectionCard({super.key, this.title, required this.items});

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

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;
  final bool showDivider;

  const ProfileTile({
    super.key,
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
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
