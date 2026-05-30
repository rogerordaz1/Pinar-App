import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../../domain/entities/negocio_detalle.dart';
import 'action_buttons_section.dart';
import 'business_info_section.dart';
import 'footer_section.dart';
import 'hero_background.dart';
import 'logo_circle.dart';
import 'productos_section.dart';
import 'section_separator.dart';

class NegocioContent extends StatelessWidget {
  final NegocioDetalle negocio;
  final double bottomPadding;

  const NegocioContent({
    super.key,
    required this.negocio,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 240,
          child: HeroBackground(negocio: negocio),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 180),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
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
                        BusinessInfoSection(negocio: negocio),
                        ActionButtonsSection(negocio: negocio),
                        const SectionSeparator(),
                        ProductosSection(negocio: negocio),
                        FooterSection(negocio: negocio),
                        SizedBox(height: bottomPadding + 16),
                      ],
                    ),
                  ),
                  const Positioned(top: 0, child: LogoCircle()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
