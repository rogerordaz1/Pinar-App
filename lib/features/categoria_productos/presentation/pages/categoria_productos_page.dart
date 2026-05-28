import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../busqueda/busqueda.dart';
import '../cubit/categoria_productos_cubit.dart';
import '../cubit/categoria_productos_state.dart';

class CategoriaProductosPage extends StatelessWidget {
  final String categoriaNombre;

  const CategoriaProductosPage({super.key, required this.categoriaNombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(categoriaNombre),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CategoriaProductosCubit, CategoriaProductosState>(
        builder: (context, state) => switch (state) {
          CategoriaProductosInitial() ||
          CategoriaProductosLoading() =>
            const Center(child: CircularProgressIndicator()),
          CategoriaProductosLoaded(:final productos) when productos.isEmpty =>
            _EmptyState(categoriaNombre: categoriaNombre),
          CategoriaProductosLoaded(:final productos) => ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: productos.length,
              itemBuilder: (_, i) => ResultadoCard(resultado: productos[i]),
            ),
          CategoriaProductosError(:final message) => _ErrorState(
              message: message,
              onRetry: () =>
                  context.read<CategoriaProductosCubit>().retry(),
            ),
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String categoriaNombre;
  const _EmptyState({required this.categoriaNombre});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.outline),
          const SizedBox(height: 12),
          Text(
            'Sin productos disponibles\nen "$categoriaNombre"',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
