import "../services/api_client.dart";

class UserModel {
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.isActive = true,
    this.avatar,
    this.lastLoginAt,
    this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // "admin" | "student"
  final bool isActive;
  final String? avatar;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  bool get isAdmin => role == "admin";
  bool get isStudent => role == "student";

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json["id"] ?? json["_id"]).toString(),
      fullName: json["fullName"]?.toString() ?? json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      phone: json["phone"]?.toString(),
      role: json["role"]?.toString() ?? "student",
      isActive: parseBool(json["isActive"], true),
      avatar: json["avatar"]?.toString(),
      lastLoginAt: json["lastLoginAt"] != null ? DateTime.tryParse(json["lastLoginAt"].toString()) : null,
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "role": role,
        "isActive": isActive,
        "avatar": avatar,
        "lastLoginAt": lastLoginAt?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
      };
}
