import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../busqueda/busqueda.dart';
import '../cubit/categoria_productos_cubit.dart';
import '../cubit/categoria_productos_state.dart';
import '../widgets/categoria_empty_state.dart';
import '../widgets/categoria_error_state.dart';

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
            CategoriaEmptyState(categoriaNombre: categoriaNombre),
          CategoriaProductosLoaded(:final productos) => ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: productos.length,
              itemBuilder: (_, i) => ResultadoCard(resultado: productos[i]),
            ),
          CategoriaProductosError(:final message) => CategoriaErrorState(
              message: message,
              onRetry: () =>
                  context.read<CategoriaProductosCubit>().retry(),
            ),
        },
      ),
    );
  }
}
