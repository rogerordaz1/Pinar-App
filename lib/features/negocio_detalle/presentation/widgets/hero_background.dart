import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';

class HeroBackground extends StatelessWidget {
  final NegocioDetalle negocio;
  const HeroBackground({super.key, required this.negocio});

  @override
  Widget build(BuildContext context) {
    if (negocio.heroImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: negocio.heroImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryContainer, AppColors.primary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.storefront_outlined, color: Colors.white54, size: 80),
      ),
    );
  }
}
