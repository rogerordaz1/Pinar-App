import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/producto_popular.dart';
import '../../domain/entities/promocion.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitial;
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.loaded({
    required List<CategoriaNegocio> categorias,
    required List<Promocion> promociones,
    required List<NegocioPreview> negocios,
    required List<ProductoPopular> productos,
  }) = HomeLoaded;
  const factory HomeState.error({required String message}) = HomeError;
}
