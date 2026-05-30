import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams extends Equatable {
  final String nombre;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? avatarLocalPath;

  const UpdateProfileParams({
    required this.nombre,
    this.direccion,
    this.lat,
    this.lng,
    this.avatarLocalPath,
  });

  @override
  List<Object?> get props => [nombre, direccion, lat, lng, avatarLocalPath];
}

class UpdateProfileUseCase extends UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}
