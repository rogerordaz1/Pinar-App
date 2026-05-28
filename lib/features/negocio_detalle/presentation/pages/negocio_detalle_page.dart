import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';

class NegocioDetallePage extends StatelessWidget {
  final String negocioId;
  const NegocioDetallePage({super.key, required this.negocioId});

  static const _mock = NegocioDetalle(
    id: '1',
    nombre: 'Finca La Esperanza',
    categoria: 'Agropecuario',
    abierto: true,
    distanciaKm: 1.2,
    verificado: true,
    calificacion: 4.8,
    totalResenas: 124,
    direccion: 'Km 4.5 Carretera a Viñales, Pinar del Río',
    telefono: '+53 48 123456',
    whatsapp: '+5348123456',
    infoEntrega: 'Entregas todos los sábados en el casco urbano',
    certificaciones: ['Orgánico', 'Sostenible', 'Directo'],
    productos: [
      ProductoNegocio(
        id: 'p1',
        nombre: 'Huevos de Campo',
        precio: 350,
        unidad: 'cartón',
        disponible: true,
        actualizadoHace: 'hace 2h',
      ),
      ProductoNegocio(
        id: 'p2',
        nombre: 'Pollo Entero Orgánico',
        precio: 1200,
        unidad: 'kg',
        disponible: true,
        actualizadoHace: 'hace 5h',
      ),
      ProductoNegocio(
        id: 'p3',
        nombre: 'Miel Multiflora',
        precio: 450,
        unidad: '500ml',
        disponible: true,
        actualizadoHace: 'hace 1d',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    const negocio = _mock;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pinar Market',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Hero image (behind scroll)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: _HeroBackground(negocio: negocio),
          ),
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 180),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // White panel — margin-top creates the logo overlap gap
                    Container(
                      margin: const EdgeInsets.only(top: 44),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 52),
                          _BusinessInfoSection(negocio: negocio),
                          _ActionButtonsSection(negocio: negocio),
                          _SectionSeparator(),
                          _ProductosSection(negocio: negocio),
                          _FooterSection(negocio: negocio),
                          SizedBox(height: bottom + 16),
                        ],
                      ),
                    ),
                    // Logo circle centered on hero/panel boundary
                    const Positioned(top: 0, child: _LogoCircle()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Background ──────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  final NegocioDetalle negocio;
  const _HeroBackground({required this.negocio});

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
        child: Icon(Icons.grass, color: Colors.white54, size: 80),
      ),
    );
  }
}

// ── Logo Circle ──────────────────────────────────────────────────────────────

class _LogoCircle extends StatelessWidget {
  const _LogoCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.surface, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.grass, color: AppColors.primary, size: 44),
    );
  }
}

// ── Business Info ────────────────────────────────────────────────────────────

class _BusinessInfoSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const _BusinessInfoSection({required this.negocio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  negocio.nombre,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              if (negocio.verificado) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: AppColors.secondary, size: 22),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _StatusBadge(abierto: negocio.abierto),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 4),
              Text(
                negocio.calificacion.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${negocio.totalResenas} reseñas)',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  negocio.direccion,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'A ${negocio.distanciaKm.toStringAsFixed(1)} km de tu ubicación',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool abierto;
  const _StatusBadge({required this.abierto});

  @override
  Widget build(BuildContext context) {
    final color = abierto ? AppColors.success : AppColors.error;
    final label = abierto ? 'Abierto ahora' : 'Cerrado';
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
            label,
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

// ── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtonsSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const _ActionButtonsSection({required this.negocio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined, size: 18),
              label: const Text('Llamar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Separator ────────────────────────────────────────────────────────

class _SectionSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 8, child: ColoredBox(color: AppColors.surfaceContainerLow));
  }
}

// ── Products Section ─────────────────────────────────────────────────────────

class _ProductosSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const _ProductosSection({required this.negocio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Productos Disponibles',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver todo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: negocio.productos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _ProductoCard(producto: negocio.productos[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final ProductoNegocio producto;
  const _ProductoCard({required this.producto});

  static const _cardWidth = 160.0;

  Color _color() {
    final name = producto.nombre.toLowerCase();
    if (name.contains('huevo')) return const Color(0xFFF9A825);
    if (name.contains('pollo')) return const Color(0xFFE65100);
    if (name.contains('miel')) return const Color(0xFFFF8F00);
    return AppColors.primary;
  }

  IconData _icon() {
    final name = producto.nombre.toLowerCase();
    if (name.contains('huevo')) return Icons.egg_outlined;
    if (name.contains('pollo')) return Icons.set_meal_outlined;
    if (name.contains('miel')) return Icons.local_florist_outlined;
    return Icons.shopping_basket_outlined;
  }

  String get _precio {
    final p = producto.precio.toInt();
    return '\$$p / ${producto.unidad}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color();
    return SizedBox(
      width: _cardWidth,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        color: AppColors.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(_icon(), color: color, size: 40)),
                  if (producto.disponible)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Disponible',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _precio,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actualizado: ${producto.actualizadoHace}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
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

// ── Footer ───────────────────────────────────────────────────────────────────

class _FooterSection extends StatelessWidget {
  final NegocioDetalle negocio;
  const _FooterSection({required this.negocio});

  @override
  Widget build(BuildContext context) {
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
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (negocio.certificaciones.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: negocio.certificaciones
                  .map((cert) => _CertBadge(cert: cert))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  final String cert;
  const _CertBadge({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        cert,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
