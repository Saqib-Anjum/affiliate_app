import "../services/api_client.dart";

class ClientModel {
  ClientModel({
    required this.id,
    required this.studentId,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.businessNiche,
    this.website,
    this.notes,
    this.emergencyMeeting = false,
    this.status = "pending",
    this.quoteAmount,
    this.discount,
    this.currency = "USD",
    this.saleAmount,
    this.payoutAmount,
    this.meetingDate,
    this.meetingTime,
    this.zoomJoinUrl,
    this.createdAt,
  });

  final String id;
  final String studentId;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? businessNiche;
  final String? website;
  final String? notes;
  final bool emergencyMeeting;
  final String status; // pending | signup | not_interested
  final double? quoteAmount;
  final double? discount;
  final String currency;
  final double? saleAmount;
  final double? payoutAmount;
  final DateTime? meetingDate;
  final String? meetingTime;
  final String? zoomJoinUrl;
  final DateTime? createdAt;

  bool get isClosedSale => status == "signup";

  // Display-only "final price" (quote minus discount) from spec section 8.
  // The backend never stores this derived value and it is never sent as
  // the authoritative sale amount -- saleAmount stays the source of truth.
  double get finalPrice => (quoteAmount ?? 0) - (discount ?? 0);

  /// Student Revenue / Payout amount.
  /// Defaults to 20% of saleAmount if payoutAmount is not explicitly set.
  double get studentRevenue => payoutAmount ?? ((saleAmount ?? 0) * 0.20);

  ClientModel copyWith({String? status, bool? emergencyMeeting}) {
    return ClientModel(
      id: id,
      studentId: studentId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      businessNiche: businessNiche,
      website: website,
      notes: notes,
      emergencyMeeting: emergencyMeeting ?? this.emergencyMeeting,
      status: status ?? this.status,
      quoteAmount: quoteAmount,
      discount: discount,
      currency: currency,
      saleAmount: saleAmount,
      payoutAmount: payoutAmount,
      meetingDate: meetingDate,
      meetingTime: meetingTime,
      zoomJoinUrl: zoomJoinUrl,
      createdAt: createdAt,
    );
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: (json["id"] ?? json["_id"]).toString(),
      studentId: (json["studentId"] ?? "").toString(),
      fullName: json["fullName"]?.toString() ?? "",
      phoneNumber: json["phoneNumber"]?.toString(),
      email: json["email"]?.toString(),
      businessNiche: json["businessNiche"]?.toString(),
      website: json["website"]?.toString(),
      notes: json["notes"]?.toString(),
      emergencyMeeting: parseBool(json["emergencyMeeting"]),
      status: json["status"]?.toString() ?? "pending",
      quoteAmount: parseDoubleNullable(json["quoteAmount"]),
      discount: parseDoubleNullable(json["discount"]),
      currency: json["currency"]?.toString() ?? "USD",
      saleAmount: parseDoubleNullable(json["saleAmount"]),
      payoutAmount: parseDoubleNullable(json["payoutAmount"]),
      meetingDate: json["meetingDate"] != null ? DateTime.tryParse(json["meetingDate"].toString()) : null,
      meetingTime: json["meetingTime"]?.toString(),
      zoomJoinUrl: json["zoomJoinUrl"]?.toString(),
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,
    );
  }

  Map<String, dynamic> toCreateJson() {
    String? clean(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
    return {
      "fullName": fullName.trim(),
      if (clean(phoneNumber) != null) "phoneNumber": clean(phoneNumber),
      if (clean(email) != null) "email": clean(email),
      if (clean(businessNiche) != null) "businessNiche": clean(businessNiche),
      if (clean(website) != null) "website": clean(website),
      if (clean(notes) != null) "notes": clean(notes),
      "emergencyMeeting": emergencyMeeting,
      "status": status,
      if (quoteAmount != null) "quoteAmount": quoteAmount,
      "currency": currency,
      if (saleAmount != null) "saleAmount": saleAmount,
      if (payoutAmount != null) "payoutAmount": payoutAmount,
    };
  }
}
