import 'package:flutter/material.dart';
import '../../../../../core/core.dart';
import '../cubit/busqueda_state.dart';
import 'resultado_card.dart';

class ResultadosSection extends StatelessWidget {
  final BusquedaState state;

  const ResultadosSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == BusquedaStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == BusquedaStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Error al buscar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    if (state.status == BusquedaStatus.loaded && state.resultados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              'Sin resultados para\n"${state.termino}"',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: state.resultados.length,
      itemBuilder: (_, i) => ResultadoCard(resultado: state.resultados[i]),
    );
  }
}
