import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/meeting_model.dart";
import "../services/api_client.dart";
import "dashboard_provider.dart";
import "service_providers.dart";

final upcomingMeetingsProvider = FutureProvider<Paginated<MeetingModel>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  return ref.watch(meetingServiceProvider).list(upcoming: true, limit: 50);
});

final allMeetingsProvider = FutureProvider<Paginated<MeetingModel>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  return ref.watch(meetingServiceProvider).list(limit: 50);
});

class MeetingActions {
  MeetingActions(this._ref);
  final Ref _ref;

  Future<MeetingModel> book(MeetingModel meeting) async {
    final created = await _ref.read(meetingServiceProvider).create(meeting);
    _ref.read(dashboardRefreshProvider.notifier).state++;
    return created;
  }

  Future<void> cancel(String id) async {
    await _ref.read(meetingServiceProvider).cancel(id);
    _ref.read(dashboardRefreshProvider.notifier).state++;
  }
}

final meetingActionsProvider = Provider((ref) => MeetingActions(ref));
