import "../models/meeting_model.dart";
import "api_client.dart";

/// Talks to /meetings, which on the backend orchestrates DB + the Zoom
/// Server-to-Server OAuth integration in one call. No Zoom credentials or
/// direct Zoom calls ever happen from this app -- see spec section 26.
class MeetingService {
  MeetingService(this._api);
  final ApiClient _api;

  Future<Paginated<MeetingModel>> list({int page = 1, int limit = 20, bool? upcoming}) {
    return _api.get(
      "/meetings",
      query: {"page": page, "limit": limit, if (upcoming != null) "upcoming": upcoming},
      parse: (body) => Paginated.fromJson(body, MeetingModel.fromJson),
    );
  }

  Future<MeetingModel> create(MeetingModel meeting) {
    return _api.post(
      "/meetings",
      data: meeting.toCreateJson(),
      parse: (body) => MeetingModel.fromJson(unwrapData(body)),
    );
  }

  Future<void> cancel(String id) {
    return _api.delete("/meetings/$id", parse: (_) {});
  }
}
