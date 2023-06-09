import 'package:auth/src/features/auth/logic/models/user.dart';
import 'package:auth/src/features/auth/logic/repository/auth_repository.dart';
import 'package:auth/src/features/notification/logic/repository/notification_repository.dart';
import 'package:bloc/bloc.dart';

class AuthCubit extends Cubit<User?> {
  AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(null);

  Future<void> authenticate(String username, String password) async {
    return _loginWith(() => authRepository.authenticate(username, password));
  }

  Future<void> register(String username, String password, String email) async {
    return _loginWith(() => authRepository.register(username, password, email));
  }

  Future<void> logoutFromAllDevices() async {
    return _loginWith(() => authRepository.logoutFromAllDevices());
  }

  Future<void> _loginWith(Function method) async {
    await method();

    return updateProfile();
  }

  Future<void> logout() async {
    emit(null);

    await authRepository.logout();

    await notificationRepository.deleteSubscription();
  }

  Future<void> updateProfile() async {
    emit(await this.authRepository.getProfile());
  }
}
