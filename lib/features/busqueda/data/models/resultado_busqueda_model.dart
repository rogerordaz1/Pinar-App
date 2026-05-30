import '../../domain/entities/resultado_busqueda.dart';

class ResultadoBusquedaModel {
  final String negocioId;
  final String negocioNombre;
  final String negocioDireccion;
  final bool negocioAbierto;
  final bool negocioVerificado;
  final String? logoUrl;
  final String productoId;
  final String productoNombre;
  final double precio;
  final bool disponible;
  final String actualizadoHace;
  final double distanciaMetros;
  final double calificacion;

  const ResultadoBusquedaModel({
    required this.negocioId,
    required this.negocioNombre,
    required this.negocioDireccion,
    required this.negocioAbierto,
    required this.negocioVerificado,
    this.logoUrl,
    required this.productoId,
    required this.productoNombre,
    required this.precio,
    required this.disponible,
    required this.actualizadoHace,
    required this.distanciaMetros,
    required this.calificacion,
  });

  factory ResultadoBusquedaModel.fromMap(Map<String, dynamic> map) {
    return ResultadoBusquedaModel(
      negocioId: map['negocio_id'] as String,
      negocioNombre: map['negocio_nombre'] as String,
      negocioDireccion: map['negocio_direccion'] as String,
      negocioAbierto: map['negocio_abierto'] as bool,
      negocioVerificado: map['negocio_verificado'] as bool? ?? false,
      logoUrl: map['logo_url'] as String?,
      productoId: map['producto_id'] as String,
      productoNombre: map['producto_nombre'] as String,
      precio: (map['precio'] as num).toDouble(),
      disponible: map['disponible'] as bool,
      actualizadoHace: _relativeTime(map['ultima_actualizacion']),
      distanciaMetros: (map['distancia_metros'] as num).toDouble(),
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _relativeTime(dynamic tsz) {
    if (tsz == null) return 'Reciente';
    try {
      final dt = DateTime.parse(tsz as String).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
      if (diff.inHours < 24) return 'hace ${diff.inHours}h';
      return 'hace ${diff.inDays}d';
    } catch (_) {
      return 'Reciente';
    }
  }

  ResultadoBusqueda toEntity() => ResultadoBusqueda(
        negocioId: negocioId,
        negocioNombre: negocioNombre,
        negocioDireccion: negocioDireccion,
        negocioAbierto: negocioAbierto,
        negocioVerificado: negocioVerificado,
        logoUrl: logoUrl,
        productoId: productoId,
        productoNombre: productoNombre,
        precio: precio,
        disponible: disponible,
        actualizadoHace: actualizadoHace,
        distanciaMetros: distanciaMetros,
        calificacion: calificacion,
      );
}
