import "../services/api_client.dart";

class DashboardStatsModel {
  DashboardStatsModel({
    required this.totalClients,
    required this.pendingClients,
    required this.signupClients,
    required this.notInterestedClients,
    required this.closedSales,
    required this.totalRevenue,
    required this.payout,
    this.emergencyMeetings = 0,
    this.upcomingMeetings = 0,
    this.recordings = 0,
    this.totalStudents,
    this.totalRecordings,
  });

  final int totalClients;
  final int pendingClients;
  final int signupClients;
  final int notInterestedClients;
  final int closedSales;
  final double totalRevenue;
  final double payout;
  final int emergencyMeetings;
  final int upcomingMeetings;
  final int recordings; // student dashboard field name
  final int? totalStudents; // admin only
  final int? totalRecordings; // admin only

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalClients: parseInt(json["totalClients"]),
      pendingClients: parseInt(json["pendingClients"]),
      signupClients: parseInt(json["signupClients"]),
      notInterestedClients: parseInt(json["notInterestedClients"]),
      closedSales: parseInt(json["closedSales"]),
      totalRevenue: parseDouble(json["totalRevenue"]),
      payout: parseDouble(json["payout"]),
      emergencyMeetings: parseInt(json["emergencyMeetings"]),
      upcomingMeetings: parseInt(json["upcomingMeetings"]),
      recordings: parseInt(json["recordings"]),
      totalStudents: parseIntNullable(json["totalStudents"]),
      totalRecordings: parseIntNullable(json["totalRecordings"]),
    );
  }
}
