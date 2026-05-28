import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => state.map(
        initial: (_) => const Center(child: CircularProgressIndicator()),
        loading: (_) => const Center(child: CircularProgressIndicator()),
        loaded: (s) => HomeContent(
          categorias: s.categorias,
          promociones: s.promociones,
          negocios: s.negocios,
          productos: s.productos,
        ),
        error: (s) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(s.message),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<HomeCubit>().loadHome(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
