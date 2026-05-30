import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final String? avatarUrl;
  final bool esNegocio;
  final String? direccion;
  final double? lat;
  final double? lng;

  const UserEntity({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    this.avatarUrl,
    this.esNegocio = false,
    this.direccion,
    this.lat,
    this.lng,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? nombre,
    String? telefono,
    String? avatarUrl,
    bool? esNegocio,
    String? direccion,
    double? lat,
    double? lng,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      esNegocio: esNegocio ?? this.esNegocio,
      direccion: direccion ?? this.direccion,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, nombre, telefono, avatarUrl, esNegocio, direccion, lat, lng];
}
