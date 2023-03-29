import 'package:auth/src/features/auth/logic/interceptors/auth_token_interceptor.dart';
import 'package:auth/src/features/auth/logic/models/tokens.dart';
import 'package:auth/src/features/auth/logic/models/user.dart';
import 'package:auth/src/shared/logic/http/api.dart';
import 'package:auth/src/shared/logic/http/interceptors/error_dialog_interceptor.dart';

class AuthAPIProvider {
  Future<Tokens> authenticate(String username, String password) async {
    final response = await api.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final tokens = Tokens.fromJson(response.data);

    return tokens;
  }

  Future<Tokens> register(
    String username,
    String password,
    String email,
  ) async {
    final response = await api.post(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
      },
    );

    final tokens = Tokens.fromJson(response.data);

    return tokens;
  }

  Future<void> recover(String email) async {
    await api.post(
      '/recover',
      data: {
        'email': email,
      },
    );
  }

  Future<User?> getProfile() async {
    final response = await api.get(
      '/auth/me',
      options: Options(
        headers: {
          ErrorDialogInterceptor.skipHeader: true,
        },
      ),
    );

    return User.fromJson(response.data);
  }

  Future<Tokens> loginWithRefreshToken(String? refreshToken) async {
    final response = await api.post(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {AuthTokenInterceptor.skipHeader: true}),
    );

    return Tokens.fromJson(response.data);
  }

  Future<Tokens> logoutFromAllDevices() async {
    final response = await api.delete('/auth/logout-from-all-devices');

    return Tokens.fromJson(response.data);
  }
}
