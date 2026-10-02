import "../services/api_client.dart";

class RecordingModel {
  RecordingModel({
    required this.id,
    required this.recordingId,
    required this.meetingId,
    required this.clientId,
    required this.studentId,
    required this.recordingUrl,
    this.downloadUrl,
    this.recordingType,
    this.duration,
    this.recordingDate,
    this.passwordRequired = false,
    this.clientName,
    this.meetingTopic,
  });

  final String id;
  final String recordingId;
  final String meetingId;
  final String clientId;
  final String studentId;
  final String recordingUrl;
  final String? downloadUrl;
  final String? recordingType;
  final int? duration; // seconds
  final DateTime? recordingDate;
  final bool passwordRequired;

  // Populated client-side after joining with client/meeting lookups, since
  // the backend recording record only stores ids.
  final String? clientName;
  final String? meetingTopic;

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: (json["id"] ?? json["_id"]).toString(),
      recordingId: json["recordingId"]?.toString() ?? "",
      meetingId: json["meetingId"]?.toString() ?? "",
      clientId: (json["clientId"] ?? "").toString(),
      studentId: (json["studentId"] ?? "").toString(),
      recordingUrl: json["recordingUrl"]?.toString() ?? "",
      downloadUrl: json["downloadUrl"]?.toString(),
      recordingType: json["recordingType"]?.toString(),
      duration: parseIntNullable(json["duration"]),
      recordingDate: json["recordingDate"] != null ? DateTime.tryParse(json["recordingDate"].toString()) : null,
      passwordRequired: parseBool(json["passwordRequired"]),
    );
  }
}
