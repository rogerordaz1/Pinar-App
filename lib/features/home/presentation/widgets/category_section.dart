import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../domain/entities/categoria_negocio.dart';
import 'category_chip.dart';
import 'home_section_header.dart';

class CategorySection extends StatelessWidget {
  final List<CategoriaNegocio> categorias;
  const CategorySection({super.key, required this.categorias});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(titulo: 'Categorías'),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => CategoryChip(
              categoria: categorias[index],
              onTap: () => context.go(
                RouteNames.busqueda,
                extra: categorias[index].id,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
