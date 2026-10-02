import "dart:convert";
import "../models/user_model.dart";
import "api_client.dart";
import "storage_service.dart";

class AuthResult {
  AuthResult(this.user, this.accessToken, this.refreshToken);
  final UserModel user;
  final String accessToken;
  final String refreshToken;
}

class AuthService {
  AuthService(this._api, this._storage);
  final ApiClient _api;
  final StorageService _storage;

  Future<AuthResult> login(String email, String password) async {
    final result = await _api.post<AuthResult>(
      "/auth/login",
      data: {"email": email, "password": password},
      parse: (body) {
        final data = unwrapData(body);
        return AuthResult(
          UserModel.fromJson(data["user"]),
          data["accessToken"],
          data["refreshToken"],
        );
      },
    );
    await _storage.saveSession(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      userJson: jsonEncode(result.user.toJson()),
    );
    return result;
  }

  Future<UserModel?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null) return null;
    final userJson = await _storage.getUserJson();
    if (userJson == null) return null;
    try {
      // Validate the token is still accepted by the backend.
      return await _api.get<UserModel>("/auth/me", parse: (body) => UserModel.fromJson(unwrapData(body)));
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post("/auth/logout", parse: (_) => null);
    } catch (_) {
      // Stateless JWT -- logging out locally is what matters.
    }
    await _storage.clear();
  }
}
