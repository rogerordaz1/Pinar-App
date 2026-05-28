import 'package:flutter/material.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/producto_popular.dart';
import '../../domain/entities/promocion.dart';
import 'category_section.dart';
import 'home_header.dart';
import 'home_section_header.dart';
import 'negocio_card.dart';
import 'productos_section.dart';
import 'promo_section.dart';
import 'search_bar_tap.dart';

class HomeContent extends StatelessWidget {
  final List<CategoriaNegocio> categorias;
  final List<Promocion> promociones;
  final List<NegocioPreview> negocios;
  final List<ProductoPopular> productos;

  const HomeContent({
    super.key,
    required this.categorias,
    required this.promociones,
    required this.negocios,
    required this.productos,
  });

  @override
  Widget build(BuildContext context) {
    final tiendasAbiertas = negocios.where((n) => n.abierto).length;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(tiendasAbiertas: tiendasAbiertas),
          ),
          const SliverToBoxAdapter(child: SearchBarTap()),
          SliverToBoxAdapter(
            child: CategorySection(categorias: categorias),
          ),
          SliverToBoxAdapter(
            child: PromoSection(promociones: promociones),
          ),
          SliverToBoxAdapter(
            child: ProductosSection(productos: productos),
          ),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              titulo: 'Negocios Destacados',
              onVerTodos: () {},
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => NegocioCard(negocio: negocios[index]),
              childCount: negocios.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
