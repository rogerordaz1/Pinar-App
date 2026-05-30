import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../cubit/busqueda_cubit.dart';
import '../cubit/busqueda_state.dart';
import '../widgets/busqueda_search_header.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/recomendados_section.dart';
import '../widgets/resultados_section.dart';

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
            BusquedaSearchHeader(controller: _controller),
            const FilterChipsRow(),
            Expanded(
              child: BlocBuilder<BusquedaCubit, BusquedaState>(
                builder: (context, state) {
                  if (state.termino.isEmpty) {
                    return RecomendadosSection(state: state);
                  }
                  return ResultadosSection(state: state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
