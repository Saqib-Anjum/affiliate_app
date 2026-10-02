import "../models/bank_details_model.dart";
import "../models/payout_model.dart";
import "api_client.dart";

class PaymentService {
  PaymentService(this._api);
  final ApiClient _api;

  Future<BankDetailsModel?> getOwnBankDetails() async {
    try {
      return await _api.get("/bank-details", parse: (body) => BankDetailsModel.fromJson(unwrapData(body)));
    } catch (_) {
      return null; // not yet submitted
    }
  }

  Future<BankDetailsModel> saveBankDetails(Map<String, dynamic> payload) {
    return _api.post("/bank-details", data: payload, parse: (body) => BankDetailsModel.fromJson(unwrapData(body)));
  }

  Future<Paginated<PayoutModel>> listPayouts({int page = 1, int limit = 20, String? status}) {
    return _api.get(
      "/payouts",
      query: {"page": page, "limit": limit, if (status != null && status.isNotEmpty) "status": status},
      parse: (body) => Paginated.fromJson(body, PayoutModel.fromJson),
    );
  }
}
