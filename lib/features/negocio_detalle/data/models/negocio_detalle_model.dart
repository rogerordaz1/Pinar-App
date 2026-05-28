import '../../domain/entities/negocio_detalle.dart';

class NegocioDetalleModel {
  final String id;
  final String nombre;
  final String categoria;
  final bool abierto;
  final bool verificado;
  final double calificacion;
  final int totalResenas;
  final String direccion;
  final String? telefono;
  final String? whatsapp;
  final String? logoUrl;
  final String? heroImageUrl;
  final double distanciaKm;
  final List<ProductoNegocio> productos;

  const NegocioDetalleModel({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.abierto,
    required this.verificado,
    required this.calificacion,
    required this.totalResenas,
    required this.direccion,
    this.telefono,
    this.whatsapp,
    this.logoUrl,
    this.heroImageUrl,
    required this.distanciaKm,
    required this.productos,
  });

  factory NegocioDetalleModel.fromMaps(
    Map<String, dynamic> n,
    List<Map<String, dynamic>> ps,
  ) {
    return NegocioDetalleModel(
      id: n['id'] as String,
      nombre: n['nombre'] as String,
      categoria: n['categoria'] as String,
      abierto: n['abierto'] as bool,
      verificado: n['verificado'] as bool,
      calificacion: (n['calificacion'] as num).toDouble(),
      totalResenas: (n['total_resenas'] as num).toInt(),
      direccion: n['direccion'] as String,
      telefono: n['telefono'] as String?,
      whatsapp: n['whatsapp'] as String?,
      logoUrl: n['logo_url'] as String?,
      heroImageUrl: n['hero_image_url'] as String?,
      distanciaKm: (n['distancia_km'] as num).toDouble(),
      productos: ps.map(_productoFromMap).toList(),
    );
  }

  static ProductoNegocio _productoFromMap(Map<String, dynamic> p) {
    return ProductoNegocio(
      id: p['id'] as String,
      nombre: p['nombre'] as String,
      precio: (p['precio'] as num).toDouble(),
      unidad: p['unidad'] as String,
      disponible: p['disponible'] as bool,
      imagenUrl: p['imagen_url'] as String?,
      actualizadoHace: _relativeTime(p['ultima_actualizacion']),
    );
  }

  static String _relativeTime(dynamic tsz) {
    if (tsz == null) return 'recién actualizado';
    final dt = DateTime.tryParse(tsz.toString());
    if (dt == null) return 'recién actualizado';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return 'hace más de una semana';
  }

  NegocioDetalle toEntity() => NegocioDetalle(
        id: id,
        nombre: nombre,
        categoria: categoria,
        abierto: abierto,
        distanciaKm: distanciaKm,
        logoUrl: logoUrl,
        heroImageUrl: heroImageUrl,
        verificado: verificado,
        calificacion: calificacion,
        totalResenas: totalResenas,
        direccion: direccion,
        telefono: telefono,
        whatsapp: whatsapp,
        productos: productos,
      );
}
