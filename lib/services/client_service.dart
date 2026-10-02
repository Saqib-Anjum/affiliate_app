import "../models/client_model.dart";
import "api_client.dart";

class ClientService {
  ClientService(this._api);
  final ApiClient _api;

  Future<Paginated<ClientModel>> list({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? businessNiche,
    bool? emergency,
  }) {
    return _api.get(
      "/clients",
      query: {
        "page": page,
        "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (status != null && status.isNotEmpty) "status": status,
        if (businessNiche != null && businessNiche.isNotEmpty) "businessNiche": businessNiche,
        if (emergency != null) "emergency": emergency,
      },
      parse: (body) => Paginated.fromJson(body, ClientModel.fromJson),
    );
  }

  Future<ClientModel> getOne(String id) {
    return _api.get("/clients/$id", parse: (body) => ClientModel.fromJson(unwrapData(body)));
  }

  Future<ClientModel> create(ClientModel client) {
    return _api.post(
      "/clients",
      data: client.toCreateJson(),
      parse: (body) => ClientModel.fromJson(unwrapData(body)),
    );
  }

  Future<ClientModel> update(String id, Map<String, dynamic> patch) {
    return _api.patch("/clients/$id", data: patch, parse: (body) => ClientModel.fromJson(unwrapData(body)));
  }

  /// Rules 2/4/5/6: changing status is what moves a client in/out of
  /// "closed sale" -- handled entirely server-side; this just persists it.
  Future<ClientModel> updateStatus(String id, String status) {
    return _api.patch(
      "/clients/$id/status",
      data: {"status": status},
      parse: (body) => ClientModel.fromJson(unwrapData(body)),
    );
  }

  Future<void> delete(String id) {
    return _api.delete("/clients/$id", parse: (_) {});
  }
}
