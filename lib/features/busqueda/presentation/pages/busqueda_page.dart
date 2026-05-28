import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../cubit/busqueda_cubit.dart';
import '../cubit/busqueda_state.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';
import '../widgets/recomendado_card.dart';
import '../widgets/resultado_card.dart';

class BusquedaPage extends StatefulWidget {
  const BusquedaPage({super.key});

  @override
  State<BusquedaPage> createState() => _BusquedaPageState();
}

class _BusquedaPageState extends State<BusquedaPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<BusquedaCubit>().state.termino,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(controller: _controller),
            _FilterChipsRow(),
            Expanded(
              child: BlocBuilder<BusquedaCubit, BusquedaState>(
                builder: (context, state) {
                  if (state.termino.isEmpty) {
                    return _RecomendadosSection(state: state);
                  }
                  return _ResultadosSection(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;

  const _SearchHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: context.read<BusquedaCubit>().onTerminoChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      context
                          .read<BusquedaCubit>()
                          .onTerminoChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaCubit, BusquedaState>(
      buildWhen: (prev, curr) =>
          prev.orden != curr.orden ||
          prev.soloAbiertos != curr.soloAbiertos,
      builder: (context, state) {
        final cubit = context.read<BusquedaCubit>();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _OrdenChip(
                label: 'Cerca',
                icon: Icons.near_me_outlined,
                selected: state.orden == OrdenBusqueda.distancia,
                onSelected: (_) => cubit.setOrden(OrdenBusqueda.distancia),
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Abierto',
                icon: Icons.door_front_door_outlined,
                selected: state.soloAbiertos,
                onSelected: (_) => cubit.toggleSoloAbiertos(),
              ),
              const SizedBox(width: 8),
              _OrdenChip(
                label: 'Más barato',
                icon: Icons.attach_money,
                selected: state.orden == OrdenBusqueda.precio,
                onSelected: (_) => cubit.setOrden(OrdenBusqueda.precio),
              ),
              const SizedBox(width: 8),
              _OrdenChip(
                label: 'Mejor valorado',
                icon: Icons.star_outline,
                selected: state.orden == OrdenBusqueda.calificacion,
                onSelected: (_) =>
                    cubit.setOrden(OrdenBusqueda.calificacion),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrdenChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _OrdenChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.outlineVariant,
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppColors.success.withOpacity(0.15),
      checkmarkColor: AppColors.success,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.success : AppColors.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppColors.success : AppColors.outlineVariant,
      ),
    );
  }
}

class _RecomendadosSection extends StatelessWidget {
  final BusquedaState state;

  const _RecomendadosSection({required this.state});

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
            child: Text('Recomendados para ti',
                style: AppTextStyles.heading3),
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

class _ResultadosSection extends StatelessWidget {
  final BusquedaState state;

  const _ResultadosSection({required this.state});

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
            Text(state.errorMessage ?? 'Error al buscar',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    if (state.status == BusquedaStatus.loaded &&
        state.resultados.isEmpty) {
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
      itemBuilder: (_, i) =>
          ResultadoCard(resultado: state.resultados[i]),
    );
  }
}
