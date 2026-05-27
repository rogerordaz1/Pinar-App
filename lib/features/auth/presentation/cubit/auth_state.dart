import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object> get props => [];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object> get props => [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
  @override
  List<Object> get props => [];
}

class AuthOtpVerified extends AuthState {
  const AuthOtpVerified();
  @override
  List<Object> get props => [];
}

class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
  @override
  List<Object> get props => [];
}
