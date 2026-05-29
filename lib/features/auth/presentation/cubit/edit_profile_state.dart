import '../../domain/entities/user_entity.dart';

sealed class EditProfileState {
  const EditProfileState();
}

final class EditProfileIdle extends EditProfileState {
  const EditProfileIdle();
}

final class EditProfileSaving extends EditProfileState {
  const EditProfileSaving();
}

final class EditProfileSuccess extends EditProfileState {
  final UserEntity user;
  const EditProfileSuccess(this.user);
  @override
  bool operator ==(Object other) =>
      other is EditProfileSuccess && other.user == user;
  @override
  int get hashCode => user.hashCode;
}

final class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
  @override
  bool operator ==(Object other) =>
      other is EditProfileError && other.message == message;
  @override
  int get hashCode => message.hashCode;
}
