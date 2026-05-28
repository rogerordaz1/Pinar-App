import 'package:flutter/material.dart';
import '../../domain/entities/producto_popular.dart';
import 'home_section_header.dart';
import 'producto_card.dart';

class ProductosSection extends StatelessWidget {
  final List<ProductoPopular> productos;
  const ProductosSection({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    if (productos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(titulo: 'Productos Populares Hoy', onVerTodos: () {}),
        SizedBox(
          height: 192,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: productos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                ProductoCard(producto: productos[index]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
