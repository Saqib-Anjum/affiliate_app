import "../models/user_model.dart";
import "api_client.dart";

/// Admin-only: managing student accounts (spec section 14).
class StudentService {
  StudentService(this._api);
  final ApiClient _api;

  Future<Paginated<UserModel>> list({int page = 1, int limit = 20, String? search}) {
    return _api.get(
      "/students",
      query: {"page": page, "limit": limit, if (search != null && search.isNotEmpty) "search": search},
      parse: (body) => Paginated.fromJson(body, UserModel.fromJson),
    );
  }

  Future<UserModel> create({required String fullName, required String email, String? phone, required String password}) {
    return _api.post(
      "/students",
      data: {"fullName": fullName, "email": email, if (phone != null) "phone": phone, "password": password},
      parse: (body) => UserModel.fromJson(unwrapData(body)),
    );
  }

  Future<void> setActive(String id, bool isActive) {
    return _api.patch("/students/$id/status", data: {"isActive": isActive}, parse: (_) {});
  }

  Future<void> resetPassword(String id, String newPassword) {
    return _api.post("/students/$id/reset-password", data: {"newPassword": newPassword}, parse: (_) {});
  }

  Future<void> delete(String id) {
    return _api.delete("/students/$id", parse: (_) {});
  }
}
