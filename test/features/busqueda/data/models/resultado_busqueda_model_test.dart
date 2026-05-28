import 'package:flutter_test/flutter_test.dart';
import 'package:cubamap/features/busqueda/data/models/resultado_busqueda_model.dart';
import 'package:cubamap/features/busqueda/domain/entities/resultado_busqueda.dart';

void main() {
  final tMap = {
    'negocio_id': 'n001',
    'negocio_nombre': 'Panadería Elena',
    'negocio_direccion': 'Calle Martí 23',
    'negocio_abierto': true,
    'negocio_verificado': true,
    'logo_url': 'https://images.unsplash.com/photo-123',
    'producto_id': 'p001',
    'producto_nombre': 'Pan Criollo',
    'precio': 25.0,
    'disponible': true,
    'ultima_actualizacion': null,
    'distancia_metros': 300.0,
    'calificacion': 4.8,
  };

  group('ResultadoBusquedaModel.fromMap', () {
    test('mapea correctamente los campos obligatorios', () {
      final model = ResultadoBusquedaModel.fromMap(tMap);

      expect(model.negocioId, 'n001');
      expect(model.negocioNombre, 'Panadería Elena');
      expect(model.negocioDireccion, 'Calle Martí 23');
      expect(model.negocioAbierto, true);
      expect(model.negocioVerificado, true);
      expect(model.logoUrl, 'https://images.unsplash.com/photo-123');
      expect(model.productoId, 'p001');
      expect(model.productoNombre, 'Pan Criollo');
      expect(model.precio, 25.0);
      expect(model.disponible, true);
      expect(model.distanciaMetros, 300.0);
      expect(model.calificacion, 4.8);
    });

    test('retorna "Reciente" cuando ultima_actualizacion es null', () {
      final model = ResultadoBusquedaModel.fromMap(tMap);
      expect(model.actualizadoHace, 'Reciente');
    });

    test('formatea ultima_actualizacion como tiempo relativo', () {
      final ahora = DateTime.now().toUtc();
      final hace30min =
          ahora.subtract(const Duration(minutes: 30)).toIso8601String();
      final map = Map<String, dynamic>.from(tMap)
        ..['ultima_actualizacion'] = hace30min;

      final model = ResultadoBusquedaModel.fromMap(map);
      expect(model.actualizadoHace, 'hace 30min');
    });

    test('acepta precio como entero (int)', () {
      final map = Map<String, dynamic>.from(tMap)..['precio'] = 25;
      final model = ResultadoBusquedaModel.fromMap(map);
      expect(model.precio, 25.0);
    });

    test('negocio_verificado es false cuando está ausente', () {
      final map = Map<String, dynamic>.from(tMap)
        ..remove('negocio_verificado');
      final model = ResultadoBusquedaModel.fromMap(map);
      expect(model.negocioVerificado, false);
    });

    test('logoUrl puede ser null', () {
      final map = Map<String, dynamic>.from(tMap)..['logo_url'] = null;
      final model = ResultadoBusquedaModel.fromMap(map);
      expect(model.logoUrl, isNull);
    });
  });

  group('ResultadoBusquedaModel.toEntity', () {
    test('convierte correctamente a entidad ResultadoBusqueda', () {
      final model = ResultadoBusquedaModel.fromMap(tMap);
      final entity = model.toEntity();

      expect(entity, isA<ResultadoBusqueda>());
      expect(entity.negocioId, model.negocioId);
      expect(entity.productoNombre, model.productoNombre);
      expect(entity.precio, model.precio);
      expect(entity.distanciaMetros, model.distanciaMetros);
      expect(entity.calificacion, model.calificacion);
    });
  });
}
