import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/recording_model.dart";
import "../services/api_client.dart";
import "service_providers.dart";

final recordingsProvider = FutureProvider<Paginated<RecordingModel>>((ref) async {
  return ref.watch(recordingServiceProvider).list(limit: 50);
});

final clientRecordingsProvider = FutureProvider.family<List<RecordingModel>, String>((ref, clientId) async {
  return ref.watch(recordingServiceProvider).forClient(clientId);
});
