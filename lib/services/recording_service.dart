import "../models/recording_model.dart";
import "api_client.dart";

class RecordingService {
  RecordingService(this._api);
  final ApiClient _api;

  Future<Paginated<RecordingModel>> list({int page = 1, int limit = 20}) {
    return _api.get(
      "/recordings",
      query: {"page": page, "limit": limit},
      parse: (body) => Paginated.fromJson(body, RecordingModel.fromJson),
    );
  }

  Future<List<RecordingModel>> forClient(String clientId) {
    return _api.get(
      "/clients/$clientId/recordings",
      parse: (body) => (unwrapData(body) as List).map((e) => RecordingModel.fromJson(e)).toList(),
    );
  }
}
