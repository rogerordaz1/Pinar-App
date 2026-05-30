import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_cubit.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthCubit authCubit;

  EditProfileCubit({
    required this.updateProfileUseCase,
    required this.authCubit,
  }) : super(const EditProfileIdle());

  Future<void> save({
    required String nombre,
    String? direccion,
    double? lat,
    double? lng,
    String? avatarLocalPath,
  }) async {
    emit(const EditProfileSaving());
    final result = await updateProfileUseCase(
      UpdateProfileParams(
        nombre: nombre,
        direccion: direccion,
        lat: lat,
        lng: lng,
        avatarLocalPath: avatarLocalPath,
      ),
    );
    result.fold(
      (failure) => emit(EditProfileError(failure.message)),
      (user) {
        authCubit.updateUser(user);
        emit(EditProfileSuccess(user));
      },
    );
  }
}
