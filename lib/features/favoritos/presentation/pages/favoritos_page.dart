import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../widgets/negocios_tab.dart';
import '../widgets/productos_tab.dart';

class FavoritosPage extends StatelessWidget {
  final int initialTabIndex;

  const FavoritosPage({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Column(
        children: const [
          TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Negocios'),
              Tab(text: 'Productos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                NegociosTab(),
                ProductosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
