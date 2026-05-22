// test/core/errors/failures_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pinar_app/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('dos instancias con el mismo mensaje son iguales', () {
      const f1 = ServerFailure('error del servidor');
      const f2 = ServerFailure('error del servidor');
      expect(f1, equals(f2));
    });

    test('instancias con distinto mensaje no son iguales', () {
      const f1 = ServerFailure('error A');
      const f2 = ServerFailure('error B');
      expect(f1, isNot(equals(f2)));
    });
  });

  group('NetworkFailure', () {
    test('usa mensaje por defecto cuando no se provee ninguno', () {
      const f = NetworkFailure();
      expect(f.message, 'No hay conexión a internet');
    });

    test('dos instancias sin mensaje son iguales', () {
      expect(const NetworkFailure(), equals(const NetworkFailure()));
    });
  });

  group('AuthFailure', () {
    test('dos instancias con el mismo mensaje son iguales', () {
      expect(
        const AuthFailure('credenciales inválidas'),
        equals(const AuthFailure('credenciales inválidas')),
      );
    });
  });
}
