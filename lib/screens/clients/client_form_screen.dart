import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/constants/app_constants.dart";
import "../../core/validators/validators.dart";
import "../../core/widgets/custom_button.dart";
import "../../models/client_model.dart";
import "../../providers/auth_provider.dart";
import "../../providers/client_provider.dart";
import "../../widgets/app_header.dart";

/// Handles both "create" (client == null) and editing an existing client.
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.existing});
  final ClientModel? existing;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;
  late TextEditingController _quoteController;
  late TextEditingController _discountController;
  late TextEditingController _saleController;
  late TextEditingController _studentRevenueController;

  String? _niche;
  bool _customNiche = false;
  final _customNicheController = TextEditingController();
  bool _emergency = false;
  bool _saving = false;
  String? _error;
  bool _userEditedRevenue = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _nameController = TextEditingController(text: c?.fullName ?? "");
    _phoneController = TextEditingController(text: c?.phoneNumber ?? "");
    _emailController = TextEditingController(text: c?.email ?? "");
    _websiteController = TextEditingController(text: c?.website ?? "");
    _notesController = TextEditingController(text: c?.notes ?? "");
    _quoteController = TextEditingController(text: c?.quoteAmount?.toString() ?? "");
    _discountController = TextEditingController(text: c?.discount?.toString() ?? "");
    _saleController = TextEditingController(text: c?.saleAmount?.toString() ?? "");
    _studentRevenueController = TextEditingController(
      text: c?.payoutAmount?.toString() ?? (c?.saleAmount != null ? (c!.saleAmount! * 0.20).toStringAsFixed(2) : ""),
    );

    if (c?.payoutAmount != null) {
      _userEditedRevenue = true;
    }

    _emergency = c?.emergencyMeeting ?? false;
    if (c?.businessNiche != null && AppConstants.businessNiches.contains(c!.businessNiche)) {
      _niche = c.businessNiche;
    } else if (c?.businessNiche != null) {
      _customNiche = true;
      _customNicheController.text = c!.businessNiche!;
    }

    _saleController.addListener(_onSaleAmountChanged);
  }

  void _onSaleAmountChanged() {
    if (_userEditedRevenue) return;
    final sale = double.tryParse(_saleController.text.trim());
    if (sale != null && sale > 0) {
      final defaultRevenue = sale * 0.20;
      _studentRevenueController.text = defaultRevenue.toStringAsFixed(2);
    } else if (_saleController.text.trim().isEmpty) {
      _studentRevenueController.text = "";
    }
  }

  @override
  void dispose() {
    _saleController.removeListener(_onSaleAmountChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _quoteController.dispose();
    _discountController.dispose();
    _saleController.dispose();
    _studentRevenueController.dispose();
    _customNicheController.dispose();
    super.dispose();
  }

  String? _clean(String val) => val.trim().isEmpty ? null : val.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final isAdmin = ref.read(authProvider).user?.isAdmin ?? false;
    final niche = _customNiche ? _clean(_customNicheController.text) : _niche;
    final saleVal = isAdmin ? double.tryParse(_saleController.text.trim()) : widget.existing?.saleAmount;
    final revenueVal = isAdmin ? double.tryParse(_studentRevenueController.text.trim()) : widget.existing?.payoutAmount;

    try {
      final actions = ref.read(clientActionsProvider);
      if (_isEditing) {
        final patch = <String, dynamic>{
          "fullName": _nameController.text.trim(),
          if (_clean(_phoneController.text) != null) "phoneNumber": _clean(_phoneController.text),
          if (_clean(_emailController.text) != null) "email": _clean(_emailController.text),
          if (niche != null) "businessNiche": niche,
          if (_clean(_websiteController.text) != null) "website": _clean(_websiteController.text),
          if (_clean(_notesController.text) != null) "notes": _clean(_notesController.text),
          "emergencyMeeting": _emergency,
          if (_quoteController.text.trim().isNotEmpty)
            "quoteAmount": double.tryParse(_quoteController.text.trim()) ?? 0,
          if (isAdmin && saleVal != null) "saleAmount": saleVal,
          if (isAdmin && revenueVal != null) "payoutAmount": revenueVal,
        };
        await actions.update(widget.existing!.id, patch);
      } else {
        await actions.create(
          ClientModel(
            id: "",
            studentId: "",
            fullName: _nameController.text.trim(),
            phoneNumber: _clean(_phoneController.text),
            email: _clean(_emailController.text),
            businessNiche: niche,
            website: _clean(_websiteController.text),
            notes: _clean(_notesController.text),
            emergencyMeeting: _emergency,
            quoteAmount: double.tryParse(_quoteController.text.trim()),
            saleAmount: isAdmin ? saleVal : null,
            payoutAmount: isAdmin ? revenueVal : null,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppHeader(
        showBackButton: true,
        title: _isEditing ? "Edit Client Profile" : "New Client Entry",
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          children: [
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],

            _FormCardSection(
              title: "Basic Contact Details",
              subtitle: "Primary identification for this client",
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Client Full Name *",
                    hintText: "John Doe",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) => Validators.required(v, field: "Client name"),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "+1 (555) 000-0000",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email Address", hintText: "john@example.com", prefixIcon: Icon(Icons.email_outlined)),
                  validator: Validators.email,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _FormCardSection(
              title: "Business & Web Presence",
              subtitle: "Niche market and domain details",
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _customNiche ? "Other" : _niche,
                  decoration: const InputDecoration(
                    labelText: "Business Niche",
                    prefixIcon: Icon(Icons.work_outline_rounded),
                  ),
                  items: AppConstants.businessNiches
                      .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _customNiche = value == "Other";
                      _niche = value;
                    });
                  },
                ),
                if (_customNiche) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _customNicheController,
                    decoration: const InputDecoration(
                      labelText: "Specify Custom Niche",
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: "Website URL",
                    hintText: "https://example.com",
                    prefixIcon: Icon(Icons.language_rounded),
                  ),
                  validator: Validators.url,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _FormCardSection(
              title: "Quote & Financials",
              subtitle: isAdmin
                  ? "Quote, sale amount & student revenue share"
                  : "Initial quote and expected pricing",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quoteController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Quote Amount",
                          hintText: "0.00",
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                        validator: (v) => Validators.positiveNumber(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: "Discount",
                          hintText: "0.00",
                          prefixIcon: Icon(Icons.discount_outlined),
                        ),
                        validator: (v) => Validators.positiveNumber(v),
                      ),
                    ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _saleController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Sale Amount (Closed Sale)",
                      hintText: "e.g. 1000.00",
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (v) => Validators.positiveNumber(v),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _studentRevenueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      _userEditedRevenue = true;
                    },
                    decoration: const InputDecoration(
                      labelText: "Student Revenue (20% default of Sale)",
                      hintText: "Auto-calculated 20% or custom amount",
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      helperText: "By default, student revenue is 20% of sale amount. Admin can edit/override.",
                    ),
                    validator: (v) => Validators.positiveNumber(v),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            _FormCardSection(
              title: "Notes & Priority",
              subtitle: "Internal client notes and emergency status",
              children: [
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Notes & Requirements",
                    hintText: "Important meeting notes, client expectations, follow-up schedule…",
                    prefixIcon: Icon(Icons.sticky_note_2_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _emergency ? const Color(0xFFFEF2F2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _emergency ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFDC2626),
                    title: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: _emergency ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Emergency Client",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _emergency ? const Color(0xFF991B1B) : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      "Highlights this client for high-priority meeting scheduling",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _emergency,
                    onChanged: (v) => setState(() => _emergency = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomButton(
              label: _isEditing ? "Update Client Profile" : "Save Client",
              icon: _isEditing ? Icons.save_rounded : Icons.person_add_rounded,
              loading: _saving,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FormCardSection extends StatelessWidget {
  const _FormCardSection({required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
