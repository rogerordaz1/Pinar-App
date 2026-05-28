import 'package:flutter_test/flutter_test.dart';
import 'package:cubamap/features/negocio_detalle/data/models/negocio_detalle_model.dart';
import 'package:cubamap/features/negocio_detalle/domain/entities/negocio_detalle.dart';

void main() {
  final tNegocioMap = {
    'id': 'a0000000-0000-0000-0000-000000000001',
    'nombre': 'La Panadería Elena',
    'categoria': 'Panadería',
    'abierto': true,
    'verificado': true,
    'calificacion': 4.9,
    'total_resenas': 12,
    'direccion': 'Calle Martí 23, Centro',
    'telefono': '+5348111001',
    'whatsapp': '+5358111001',
    'logo_url': 'https://images.unsplash.com/photo-123',
    'hero_image_url': 'https://images.unsplash.com/photo-456',
    'distancia_km': 0.3,
  };

  final tProductosMap = [
    {
      'id': 'p001',
      'nombre': 'Pan Criollo',
      'precio': 25.0,
      'unidad': 'unidad',
      'disponible': true,
      'imagen_url': 'https://images.unsplash.com/photo-789',
      'ultima_actualizacion': '2026-05-28T10:00:00.000Z',
    },
    {
      'id': 'p002',
      'nombre': 'Pan Suave',
      'precio': 15.0,
      'unidad': 'unidad',
      'disponible': false,
      'imagen_url': null,
      'ultima_actualizacion': null,
    },
  ];

  group('NegocioDetalleModel.fromMaps', () {
    test('mapea correctamente los datos del negocio', () {
      final model = NegocioDetalleModel.fromMaps(tNegocioMap, tProductosMap);

      expect(model.id, 'a0000000-0000-0000-0000-000000000001');
      expect(model.nombre, 'La Panadería Elena');
      expect(model.categoria, 'Panadería');
      expect(model.abierto, true);
      expect(model.verificado, true);
      expect(model.calificacion, 4.9);
      expect(model.totalResenas, 12);
      expect(model.direccion, 'Calle Martí 23, Centro');
      expect(model.telefono, '+5348111001');
      expect(model.whatsapp, '+5358111001');
      expect(model.logoUrl, 'https://images.unsplash.com/photo-123');
      expect(model.heroImageUrl, 'https://images.unsplash.com/photo-456');
      expect(model.distanciaKm, 0.3);
    });

    test('mapea la lista de productos correctamente', () {
      final model = NegocioDetalleModel.fromMaps(tNegocioMap, tProductosMap);

      expect(model.productos.length, 2);

      final p1 = model.productos[0];
      expect(p1.id, 'p001');
      expect(p1.nombre, 'Pan Criollo');
      expect(p1.precio, 25.0);
      expect(p1.unidad, 'unidad');
      expect(p1.disponible, true);
      expect(p1.imagenUrl, 'https://images.unsplash.com/photo-789');

      final p2 = model.productos[1];
      expect(p2.disponible, false);
      expect(p2.imagenUrl, isNull);
    });

    test('retorna lista vacía cuando no hay productos', () {
      final model = NegocioDetalleModel.fromMaps(tNegocioMap, []);

      expect(model.productos, isEmpty);
    });

    test('acepta campos opcionales nulos', () {
      final mapSinOpcionales = Map<String, dynamic>.from(tNegocioMap)
        ..['telefono'] = null
        ..['whatsapp'] = null
        ..['logo_url'] = null
        ..['hero_image_url'] = null;

      final model = NegocioDetalleModel.fromMaps(mapSinOpcionales, []);

      expect(model.telefono, isNull);
      expect(model.whatsapp, isNull);
      expect(model.logoUrl, isNull);
      expect(model.heroImageUrl, isNull);
    });

    test('acepta calificacion como entero (sin decimales)', () {
      final mapConCalifInt = Map<String, dynamic>.from(tNegocioMap)
        ..['calificacion'] = 4;

      final model = NegocioDetalleModel.fromMaps(mapConCalifInt, []);

      expect(model.calificacion, 4.0);
    });
  });

  group('NegocioDetalleModel.toEntity', () {
    test('convierte correctamente al entity NegocioDetalle', () {
      final model = NegocioDetalleModel.fromMaps(tNegocioMap, tProductosMap);
      final entity = model.toEntity();

      expect(entity, isA<NegocioDetalle>());
      expect(entity.id, model.id);
      expect(entity.nombre, model.nombre);
      expect(entity.calificacion, model.calificacion);
      expect(entity.productos.length, model.productos.length);
    });

    test('los productos del entity tienen los datos correctos', () {
      final model = NegocioDetalleModel.fromMaps(tNegocioMap, tProductosMap);
      final entity = model.toEntity();

      expect(entity.productos[0].nombre, 'Pan Criollo');
      expect(entity.productos[0].precio, 25.0);
      expect(entity.productos[1].disponible, false);
    });
  });
}
