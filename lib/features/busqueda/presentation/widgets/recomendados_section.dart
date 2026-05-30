import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../cubit/busqueda_state.dart';
import 'recomendado_card.dart';

class RecomendadosSection extends StatelessWidget {
  final BusquedaState state;

  const RecomendadosSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == BusquedaStatus.loadingRecomendados) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.recomendados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 56, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'Busca productos disponibles\nen negocios cercanos',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Recomendados para ti', style: AppTextStyles.heading3),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => RecomendadoCard(negocio: state.recomendados[i]),
              childCount: state.recomendados.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
          ),
        ),
      ],
    );
  }
}
