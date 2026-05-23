import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final String? avatarUrl;
  final bool esNegocio;

  const UserEntity({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    this.avatarUrl,
    this.esNegocio = false,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? nombre,
    String? telefono,
    String? avatarUrl,
    bool? esNegocio,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      esNegocio: esNegocio ?? this.esNegocio,
    );
  }

  @override
  List<Object?> get props => [id, email, nombre, telefono, avatarUrl, esNegocio];
}
