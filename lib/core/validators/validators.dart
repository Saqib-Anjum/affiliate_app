class Validators {
  Validators._();

  static String? required(String? value, {String field = "This field"}) {
    if (value == null || value.trim().isEmpty) return "$field is required";
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // email is optional on Client
    final pattern = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$");
    if (!pattern.hasMatch(value.trim())) return "Enter a valid email address";
    return null;
  }

  static String? requiredEmail(String? value) {
    final requiredError = required(value, field: "Email");
    if (requiredError != null) return requiredError;
    return email(value);
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.length < 7) return "Enter a valid phone number";
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.startsWith("http") ? value : "https://$value");
    if (uri == null || !uri.hasAuthority) return "Enter a valid website URL";
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) return "Password must be at least 8 characters";
    return null;
  }

  static String? positiveNumber(String? value, {bool allowZero = true}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return "Enter a valid number";
    if (allowZero ? parsed < 0 : parsed <= 0) return "Enter a positive number";
    return null;
  }
}
