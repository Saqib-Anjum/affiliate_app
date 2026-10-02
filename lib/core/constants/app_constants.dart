/// App-wide constants: enums-as-strings that mirror the backend exactly,
/// plus static option lists used to build dropdowns.
class AppConstants {
  AppConstants._();

  // Base URL for the NestJS backend. Override at build time with:
  //   flutter run --dart-define=API_BASE_URL=https://affiliate.aidigitalcrm.cloud/api
  static const String apiBaseUrl = String.fromEnvironment(
    "API_BASE_URL",
    defaultValue: "https://affiliate.aidigitalcrm.cloud/api",
  );

  static const String tokenStorageKey = "csms_access_token";
  static const String refreshTokenStorageKey = "csms_refresh_token";
  static const String userStorageKey = "csms_user";

  static const List<String> clientStatuses = ["pending", "signup", "not_interested"];

  static const Map<String, String> clientStatusLabels = {
    "pending": "Pending",
    "signup": "Signup",
    "not_interested": "Not Interested",
  };

  static const List<String> businessNiches = [
    "Roofing",
    "Flooring",
    "Construction",
    "Plumbing",
    "HVAC",
    "Real Estate",
    "Law",
    "Dental",
    "Medical",
    "Restaurant",
    "Marketing",
    "E-commerce",
    "Technology",
    "Other",
  ];

  static const List<int> meetingDurations = [15, 30, 45, 60];

  static const List<String> paymentMethods = [
    "bank_transfer",
    "paypal",
    "wise",
    "mobile_wallet",
    "other",
  ];

  static const Map<String, String> paymentMethodLabels = {
    "bank_transfer": "Bank Transfer",
    "paypal": "PayPal",
    "wise": "Wise",
    "mobile_wallet": "Mobile Wallet",
    "other": "Other",
  };

  static const List<String> payoutStatuses = ["pending", "processing", "paid", "rejected"];

  static const List<String> quoteStatuses = ["draft", "sent", "accepted", "rejected"];

  static const List<String> meetingStatuses = ["scheduled", "completed", "cancelled"];
}
