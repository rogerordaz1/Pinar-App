import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/buscar_productos_usecase.dart';
import '../cubit/busqueda_cubit.dart';
import '../cubit/busqueda_state.dart';
import 'orden_chip.dart';
import 'toggle_chip.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusquedaCubit, BusquedaState>(
      buildWhen: (prev, curr) =>
          prev.orden != curr.orden || prev.soloAbiertos != curr.soloAbiertos,
      builder: (context, state) {
        final cubit = context.read<BusquedaCubit>();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              OrdenChip(
                label: 'Cerca',
                icon: Icons.near_me_outlined,
                selected: state.orden == OrdenBusqueda.distancia,
                onSelected: (_) => cubit.setOrden(OrdenBusqueda.distancia),
              ),
              const SizedBox(width: 8),
              ToggleChip(
                label: 'Abierto',
                icon: Icons.door_front_door_outlined,
                selected: state.soloAbiertos,
                onSelected: (_) => cubit.toggleSoloAbiertos(),
              ),
              const SizedBox(width: 8),
              OrdenChip(
                label: 'Más barato',
                icon: Icons.attach_money,
                selected: state.orden == OrdenBusqueda.precio,
                onSelected: (_) => cubit.setOrden(OrdenBusqueda.precio),
              ),
              const SizedBox(width: 8),
              OrdenChip(
                label: 'Mejor valorado',
                icon: Icons.star_outline,
                selected: state.orden == OrdenBusqueda.calificacion,
                onSelected: (_) => cubit.setOrden(OrdenBusqueda.calificacion),
              ),
            ],
          ),
        );
      },
    );
  }
}
