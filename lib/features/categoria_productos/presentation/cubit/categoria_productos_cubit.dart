import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_productos_por_categoria_usecase.dart';
import 'categoria_productos_state.dart';

class CategoriaProductosCubit extends Cubit<CategoriaProductosState> {
  final GetProductosPorCategoriaUseCase _getProductos;
  String _categoriaId = '';

  CategoriaProductosCubit({
    required GetProductosPorCategoriaUseCase getProductosPorCategoriaUseCase,
  })  : _getProductos = getProductosPorCategoriaUseCase,
        super(const CategoriaProductosInitial());

  Future<void> loadProductos(String categoriaId,
      [String categoriaNombre = '']) async {
    _categoriaId = categoriaId;
    emit(const CategoriaProductosLoading());
    final result = await _getProductos(
      CategoriaParams(
          categoriaId: categoriaId, categoriaNombre: categoriaNombre),
    );
    result.fold(
      (failure) => emit(CategoriaProductosError(failure.message)),
      (productos) => emit(CategoriaProductosLoaded(productos)),
    );
  }

  Future<void> retry() => loadProductos(_categoriaId);
}
