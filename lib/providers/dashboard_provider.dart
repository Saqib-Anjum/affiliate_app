import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/dashboard_stats_model.dart";
import "auth_provider.dart";
import "service_providers.dart";

/// Refetches whenever `refreshKey` changes -- bumped after any client
/// create/update/status-change so the four stat cards always reflect the
/// latest server-computed totals (spec: "dashboard must refresh automatically").
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  ref.watch(dashboardRefreshProvider);
  final role = ref.watch(authProvider).user?.role;
  final service = ref.watch(dashboardServiceProvider);
  return role == "admin" ? service.adminDashboard() : service.studentDashboard();
});

final adminRevenueByStudentProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(dashboardRefreshProvider);
  return ref.watch(dashboardServiceProvider).revenueByStudent();
});
