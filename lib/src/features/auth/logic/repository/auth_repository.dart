import 'dart:async';
import 'dart:io';
import 'package:auth/src/features/auth/logic/models/tokens.dart';
import 'package:auth/src/features/auth/logic/models/user.dart';
import 'package:auth/src/features/auth/logic/provider/auth_api_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as store;

class AuthRepository {
  final _provider = AuthAPIProvider();
  late final _storage = new store.FlutterSecureStorage();

  String getDeviceType() {
    String type = 'web';

    if (Platform.isIOS) {
      type = 'ios';
    }

    if (Platform.isAndroid) {
      type = 'android';
    }

    return type;
  }

  Future<void> logout() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }

  Future<User?> getProfile() async {
    if (await getAccessToken() == null && await getRefreshToken() == null) {
      return null;
    }

    try {
      final profile = await _provider.getProfile();

      return profile;
    } catch (e) {
      return null;
    }
  }

  Future<void> authenticate(String username, String password) async {
    return setTokens(
      await _provider.authenticate(username, password),
    );
  }

  Future<void> register(String username, String password, String email) async {
    return setTokens(
      await _provider.register(username, password, email),
    );
  }

  Future<void> loginWithRefreshToken() async {
    return setTokens(
      await _provider.loginWithRefreshToken(await getRefreshToken()),
    );
  }

  Future<void> logoutFromAllDevices() async {
    return setTokens(await _provider.logoutFromAllDevices());
  }

  Future<void> recover(String email) {
    return _provider.recover(email);
  }

  Future<String?> getAccessToken() {
    return _storage.read(key: 'accessToken');
  }

  Future<void> setAccessToken(String token) {
    return _storage.write(key: 'accessToken', value: token);
  }

  Future<void> deleteAccessToken() {
    return _storage.delete(key: 'accessToken');
  }

  Future<String?> getRefreshToken() {
    return _storage.read(key: 'refreshToken');
  }

  Future<void> setRefreshToken(String token) {
    return _storage.write(key: 'refreshToken', value: token);
  }

  Future<void> deleteRefreshToken() {
    return _storage.delete(key: 'refreshToken');
  }

  Future<void> setTokens(Tokens tokens) async {
    await setAccessToken(tokens.accessToken);
    await setRefreshToken(tokens.refreshToken);
  }
}
