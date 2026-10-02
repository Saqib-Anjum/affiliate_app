import "../models/dashboard_stats_model.dart";
import "api_client.dart";

class DashboardService {
  DashboardService(this._api);
  final ApiClient _api;

  Future<DashboardStatsModel> studentDashboard() {
    return _api.get(
      "/dashboard/student",
      parse: (body) => DashboardStatsModel.fromJson(unwrapData(body)),
    );
  }

  Future<DashboardStatsModel> adminDashboard() {
    return _api.get(
      "/dashboard/admin",
      parse: (body) => DashboardStatsModel.fromJson(unwrapData(body)),
    );
  }

  Future<List<Map<String, dynamic>>> revenueByStudent() {
    return _api.get(
      "/dashboard/admin/revenue-by-student",
      parse: (body) => List<Map<String, dynamic>>.from(unwrapData(body)),
    );
  }
}
