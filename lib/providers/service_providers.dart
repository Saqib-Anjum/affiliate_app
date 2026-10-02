import "package:flutter_riverpod/flutter_riverpod.dart";
import "../services/api_client.dart";
import "../services/auth_service.dart";
import "../services/client_service.dart";
import "../services/dashboard_service.dart";
import "../services/meeting_service.dart";
import "../services/payment_service.dart";
import "../services/recording_service.dart";
import "../services/storage_service.dart";
import "../services/student_service.dart";

/// Central dependency wiring. Every service is a thin wrapper around
/// [ApiClient], which itself owns token attachment / refresh / error mapping
/// -- see services/api_client.dart.
final storageServiceProvider = Provider((ref) => StorageService());

final apiClientProvider = Provider((ref) => ApiClient(ref.watch(storageServiceProvider)));

final authServiceProvider = Provider(
  (ref) => AuthService(ref.watch(apiClientProvider), ref.watch(storageServiceProvider)),
);

final clientServiceProvider = Provider((ref) => ClientService(ref.watch(apiClientProvider)));
final meetingServiceProvider = Provider((ref) => MeetingService(ref.watch(apiClientProvider)));
final recordingServiceProvider = Provider((ref) => RecordingService(ref.watch(apiClientProvider)));
final paymentServiceProvider = Provider((ref) => PaymentService(ref.watch(apiClientProvider)));
final dashboardServiceProvider = Provider((ref) => DashboardService(ref.watch(apiClientProvider)));
final studentServiceProvider = Provider((ref) => StudentService(ref.watch(apiClientProvider)));
