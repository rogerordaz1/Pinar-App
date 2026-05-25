import 'package:equatable/equatable.dart';
import '../../domain/entities/negocio_preview.dart';
import '../../domain/entities/categoria_negocio.dart';
import '../../domain/entities/promocion.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
  @override
  List<Object> get props => [];
}

class HomeLoaded extends HomeState {
  final List<CategoriaNegocio> categorias;
  final List<Promocion> promociones;
  final List<NegocioPreview> negocios;

  const HomeLoaded({
    required this.categorias,
    required this.promociones,
    required this.negocios,
  });

  @override
  List<Object> get props => [categorias, promociones, negocios];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object> get props => [message];
}
