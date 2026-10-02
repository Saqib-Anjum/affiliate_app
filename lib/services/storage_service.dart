import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "../core/constants/app_constants.dart";

/// Wraps flutter_secure_storage so tokens never touch SharedPreferences /
/// plain disk storage (spec section 25: "Use Secure Storage for auth tokens").
class StorageService {
  StorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveSession({required String accessToken, required String refreshToken, required String userJson}) async {
    await _storage.write(key: AppConstants.tokenStorageKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenStorageKey, value: refreshToken);
    await _storage.write(key: AppConstants.userStorageKey, value: userJson);
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.tokenStorageKey);
  Future<String?> getRefreshToken() => _storage.read(key: AppConstants.refreshTokenStorageKey);
  Future<String?> getUserJson() => _storage.read(key: AppConstants.userStorageKey);

  Future<void> updateAccessToken(String accessToken) =>
      _storage.write(key: AppConstants.tokenStorageKey, value: accessToken);

  Future<void> clear() async {
    await _storage.delete(key: AppConstants.tokenStorageKey);
    await _storage.delete(key: AppConstants.refreshTokenStorageKey);
    await _storage.delete(key: AppConstants.userStorageKey);
  }
}
