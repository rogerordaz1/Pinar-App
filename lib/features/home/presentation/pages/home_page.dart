import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/home_header.dart';
import '../widgets/negocio_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/search_bar_tap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeInitial || state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<HomeCubit>().loadHome(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is HomeLoaded) {
          return _HomeContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        const SliverToBoxAdapter(child: SearchBarTap()),
        SliverToBoxAdapter(
          child: _CategorySection(categorias: state.categorias),
        ),
        SliverToBoxAdapter(
          child: _PromoSection(promociones: state.promociones),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Negocios cercanos', style: AppTextStyles.heading3),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => NegocioCard(negocio: state.negocios[index]),
            childCount: state.negocios.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<CategoriaNegocio> categorias;
  const _CategorySection({required this.categorias});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text('Categorías', style: AppTextStyles.heading3),
        ),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => CategoryChip(
              categoria: categorias[index],
              onTap: () => context.go(
                RouteNames.busqueda,
                extra: categorias[index].id,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoSection extends StatefulWidget {
  final List<Promocion> promociones;
  const _PromoSection({required this.promociones});

  @override
  State<_PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<_PromoSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text('Promociones', style: AppTextStyles.heading3),
        ),
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
                onTap: () =>
                    context.go('/negocio/${widget.promociones[index].negocioId}'),
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
