import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/promocion.dart';
import 'home_section_header.dart';
import 'promo_banner.dart';

class PromoSection extends StatefulWidget {
  final List<Promocion> promociones;
  const PromoSection({super.key, required this.promociones});

  @override
  State<PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<PromoSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionHeader(titulo: 'Promociones'),
        SizedBox(
          height: 160,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.promociones.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == widget.promociones.length - 1 ? 16 : 8,
              ),
              child: PromoBanner(
                promocion: widget.promociones[index],
                onTap: () => context
                    .push('/negocio/${widget.promociones[index].negocioId}'),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promociones.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              width: _currentIndex == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
