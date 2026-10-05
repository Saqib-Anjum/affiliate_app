import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/constants/app_constants.dart";
import "../../core/widgets/custom_button.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/payment_provider.dart";
import "../../widgets/app_header.dart";

class BankDetailsScreen extends ConsumerStatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _method = "bank_transfer";
  final _holderController = TextEditingController();
  final _bankController = TextEditingController();
  final _accountController = TextEditingController();
  final _ibanController = TextEditingController();
  final _swiftController = TextEditingController();
  final _branchController = TextEditingController();
  final _walletProviderController = TextEditingController();
  final _walletNumberController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _holderController.dispose();
    _bankController.dispose();
    _accountController.dispose();
    _ibanController.dispose();
    _swiftController.dispose();
    _branchController.dispose();
    _walletProviderController.dispose();
    _walletNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(paymentActionsProvider).saveBankDetails({
        "paymentMethod": _method,
        if (_holderController.text.isNotEmpty) "accountHolderName": _holderController.text.trim(),
        if (_bankController.text.isNotEmpty) "bankName": _bankController.text.trim(),
        if (_accountController.text.isNotEmpty) "accountNumber": _accountController.text.trim(),
        if (_ibanController.text.isNotEmpty) "iban": _ibanController.text.trim(),
        if (_swiftController.text.isNotEmpty) "swiftBic": _swiftController.text.trim(),
        if (_branchController.text.isNotEmpty) "branchName": _branchController.text.trim(),
        if (_walletProviderController.text.isNotEmpty) "mobileWalletProvider": _walletProviderController.text.trim(),
        if (_walletNumberController.text.isNotEmpty) "mobileWalletNumber": _walletNumberController.text.trim(),
      });
      _accountController.clear();
      _ibanController.clear();
      _walletNumberController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bank details securely saved")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingAsync = ref.watch(bankDetailsProvider);

    return Scaffold(
      appBar: const AppHeader(
        showBackButton: true,
        title: "Payout & Bank Configuration",
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          existingAsync.when(
            loading: () => const LoadingWidget(),
            error: (_, __) => const SizedBox.shrink(),
            data: (details) {
              if (details == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Account Details Saved (Masked)",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Method: ${AppConstants.paymentMethodLabels[details.paymentMethod] ?? details.paymentMethod}"
                            "${details.accountNumberMasked != null ? " • Acc: ${details.accountNumberMasked}" : ""}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _FormSectionCard(
                  title: "Payout Method",
                  subtitle: "Choose how you want to receive your commission payouts",
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _method,
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      items: AppConstants.paymentMethods
                          .map((m) => DropdownMenuItem(value: m, child: Text(AppConstants.paymentMethodLabels[m]!)))
                          .toList(),
                      onChanged: (v) => setState(() => _method = v ?? _method),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _holderController,
                      decoration: const InputDecoration(
                        labelText: "Account Holder Name",
                        hintText: "Legal Full Name",
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_method == "bank_transfer" || _method == "wise" || _method == "paypal" || _method == "other")
                  _FormSectionCard(
                    title: "Bank & Account Info",
                    subtitle: "Encrypted bank connection details",
                    children: [
                      TextFormField(
                        controller: _bankController,
                        decoration: const InputDecoration(
                          labelText: "Bank Name",
                          hintText: "e.g., Chase, Wells Fargo",
                          prefixIcon: Icon(Icons.account_balance_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _accountController,
                        decoration: const InputDecoration(
                          labelText: "Account Number",
                          hintText: "••••••••",
                          prefixIcon: Icon(Icons.credit_card_rounded),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _ibanController,
                        decoration: const InputDecoration(
                          labelText: "IBAN",
                          hintText: "GB00 XXXX 0000 0000",
                          prefixIcon: Icon(Icons.numbers_rounded),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _swiftController,
                              decoration: const InputDecoration(
                                labelText: "SWIFT / BIC",
                                hintText: "BOFAUS3N",
                                prefixIcon: Icon(Icons.swap_horiz_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _branchController,
                              decoration: const InputDecoration(
                                labelText: "Branch Name",
                                hintText: "Main Branch",
                                prefixIcon: Icon(Icons.store_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                if (_method == "mobile_wallet")
                  _FormSectionCard(
                    title: "Mobile Wallet Details",
                    subtitle: "Mobile wallet provider and phone number",
                    children: [
                      TextFormField(
                        controller: _walletProviderController,
                        decoration: const InputDecoration(
                          labelText: "Provider Name",
                          hintText: "e.g., M-Pesa, GCash, Venmo",
                          prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _walletNumberController,
                        decoration: const InputDecoration(
                          labelText: "Registered Mobile Number",
                          hintText: "+1 (555) 000-0000",
                          prefixIcon: Icon(Icons.phone_android_rounded),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                CustomButton(
                  label: "Save Payout Details",
                  icon: Icons.lock_clock_rounded,
                  loading: _saving,
                  onPressed: _submit,
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text(
                      "Encrypted end-to-end. Plaintext account numbers are never displayed.",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
