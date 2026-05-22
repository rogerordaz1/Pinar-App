// lib/core/utils/either_extensions.dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

extension EitherX<L, R> on Either<L, R> {
  R get rightValue => (this as Right<L, R>).value;
  L get leftValue => (this as Left<L, R>).value;
}

extension FutureEitherX<T> on Future<Either<Failure, T>> {
  Future<T?> get nullableRight async {
    final result = await this;
    return result.fold((_) => null, (r) => r);
  }
}
