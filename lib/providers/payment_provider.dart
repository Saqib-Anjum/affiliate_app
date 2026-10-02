import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/bank_details_model.dart";
import "../models/payout_model.dart";
import "../services/api_client.dart";
import "service_providers.dart";

final bankDetailsRefreshProvider = StateProvider<int>((ref) => 0);

final bankDetailsProvider = FutureProvider<BankDetailsModel?>((ref) async {
  ref.watch(bankDetailsRefreshProvider);
  return ref.watch(paymentServiceProvider).getOwnBankDetails();
});

final payoutsProvider = FutureProvider<Paginated<PayoutModel>>((ref) async {
  return ref.watch(paymentServiceProvider).listPayouts(limit: 50);
});

class PaymentActions {
  PaymentActions(this._ref);
  final Ref _ref;

  Future<void> saveBankDetails(Map<String, dynamic> payload) async {
    await _ref.read(paymentServiceProvider).saveBankDetails(payload);
    _ref.read(bankDetailsRefreshProvider.notifier).state++;
  }
}

final paymentActionsProvider = Provider((ref) => PaymentActions(ref));
