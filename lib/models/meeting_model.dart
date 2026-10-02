import "../services/api_client.dart";

class MeetingModel {
  MeetingModel({
    required this.id,
    required this.studentId,
    required this.clientId,
    required this.topic,
    required this.startTime,
    required this.durationMinutes,
    this.timezone = "America/New_York",
    this.status = "scheduled",
    this.zoomMeetingId,
    this.zoomJoinUrl,
    this.emergency = false,
  });

  final String id;
  final String studentId;
  final String clientId;
  final String topic;
  final DateTime startTime;
  final int durationMinutes;
  final String timezone;
  final String status; // scheduled | completed | cancelled
  final String? zoomMeetingId;
  final String? zoomJoinUrl;
  final bool emergency;

  bool get isUpcoming => status == "scheduled" && startTime.isAfter(DateTime.now());

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: (json["id"] ?? json["_id"]).toString(),
      studentId: (json["studentId"] ?? "").toString(),
      clientId: (json["clientId"] ?? "").toString(),
      topic: json["topic"]?.toString() ?? "",
      startTime: DateTime.tryParse(json["startTime"]?.toString() ?? "") ?? DateTime.now(),
      durationMinutes: parseInt(json["durationMinutes"], 30),
      timezone: json["timezone"]?.toString() ?? "America/New_York",
      status: json["status"]?.toString() ?? "scheduled",
      zoomMeetingId: json["zoomMeetingId"]?.toString(),
      zoomJoinUrl: json["zoomJoinUrl"]?.toString(),
      emergency: parseBool(json["emergency"]),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        "clientId": clientId,
        "topic": topic,
        "startTime": startTime.toIso8601String(),
        "durationMinutes": durationMinutes,
        "timezone": timezone,
      };
}
