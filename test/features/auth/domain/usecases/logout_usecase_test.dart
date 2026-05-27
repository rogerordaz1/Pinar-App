import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cubamap/core/errors/failures.dart';
import 'package:cubamap/core/usecases/usecase.dart';
import 'package:cubamap/features/auth/domain/repositories/auth_repository.dart';
import 'package:cubamap/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LogoutUseCase(mockRepo);
  });

  group('LogoutUseCase', () {
    test('devuelve Right(void) cuando el logout es exitoso', () async {
      when(() => mockRepo.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(const NoParams());

      expect(result.isRight(), true);
      verify(() => mockRepo.logout()).called(1);
    });

    test('devuelve ServerFailure cuando el logout falla', () async {
      when(() => mockRepo.logout()).thenAnswer(
          (_) async => const Left(ServerFailure('Error al cerrar sesión')));

      final result = await useCase(const NoParams());

      expect(result, const Left(ServerFailure('Error al cerrar sesión')));
    });
  });
}
