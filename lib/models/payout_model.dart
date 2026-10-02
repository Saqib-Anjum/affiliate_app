import "../services/api_client.dart";

class PayoutModel {
  PayoutModel({
    required this.id,
    required this.studentId,
    required this.amount,
    this.status = "pending",
    this.paymentReference,
    this.adminNote,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final double amount;
  final String status; // pending | processing | paid | rejected
  final String? paymentReference;
  final String? adminNote;
  final DateTime? createdAt;

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: (json["id"] ?? json["_id"]).toString(),
      studentId: (json["studentId"] ?? "").toString(),
      amount: parseDouble(json["amount"]),
      status: json["status"]?.toString() ?? "pending",
      paymentReference: json["paymentReference"]?.toString(),
      adminNote: json["adminNote"]?.toString(),
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,
    );
  }
}
