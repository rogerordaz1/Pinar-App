import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';
import 'cert_badge.dart';

class FooterSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const FooterSection({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    final hasContent =
        negocio.infoEntrega != null || negocio.certificaciones.isNotEmpty;
    if (!hasContent) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (negocio.infoEntrega != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    negocio.infoEntrega!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (negocio.certificaciones.isNotEmpty) const SizedBox(height: 12),
          ],
          if (negocio.certificaciones.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: negocio.certificaciones
                  .map((cert) => CertBadge(cert: cert))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
