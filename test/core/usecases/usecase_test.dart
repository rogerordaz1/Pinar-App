// test/core/usecases/usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinar_app/core/errors/failures.dart';
import 'package:pinar_app/core/usecases/usecase.dart';

class _EchoUseCase extends UseCase<String, String> {
  @override
  Future<Either<Failure, String>> call(String params) async {
    return Right(params);
  }
}

class _FailingUseCase extends UseCase<String, NoParams> {
  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return const Left(ServerFailure('algo salió mal'));
  }
}

void main() {
  group('UseCase', () {
    test('devuelve Right con el valor cuando tiene éxito', () async {
      final useCase = _EchoUseCase();
      final result = await useCase('hola');
      expect(result, const Right('hola'));
    });

    test('devuelve Left con Failure cuando falla', () async {
      final useCase = _FailingUseCase();
      final result = await useCase(const NoParams());
      expect(result, const Left(ServerFailure('algo salió mal')));
    });
  });

  group('NoParams', () {
    test('dos instancias de NoParams son iguales', () {
      expect(const NoParams(), equals(const NoParams()));
    });

    test('props está vacío', () {
      expect(const NoParams().props, isEmpty);
    });
  });
}
