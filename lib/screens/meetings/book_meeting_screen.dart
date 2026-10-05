import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/constants/app_constants.dart";
import "../../core/validators/validators.dart";
import "../../core/widgets/custom_button.dart";
import "../../models/meeting_model.dart";
import "../../providers/client_provider.dart";
import "../../providers/meeting_provider.dart";
import "../../widgets/app_header.dart";

class BookMeetingScreen extends ConsumerStatefulWidget {
  const BookMeetingScreen({super.key, this.clientId, this.clientName});
  final String? clientId;
  final String? clientName;

  @override
  ConsumerState<BookMeetingScreen> createState() => _BookMeetingScreenState();
}

class _BookMeetingScreenState extends ConsumerState<BookMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  String? _selectedClientId;
  String? _selectedClientName;
  DateTime? _date;
  TimeOfDay? _time;
  int _duration = 30;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.clientId;
    _selectedClientName = widget.clientName;
    if (_selectedClientName != null) {
      _topicController.text = "Consultation with $_selectedClientName";
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      setState(() => _error = "Select a client for this meeting");
      return;
    }
    if (_date == null || _time == null) {
      setState(() => _error = "Select a meeting date and time");
      return;
    }

    final startTime = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(meetingActionsProvider).book(
            MeetingModel(
              id: "",
              studentId: "",
              clientId: _selectedClientId!,
              topic: _topicController.text.trim(),
              startTime: startTime,
              durationMinutes: _duration,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        showBackButton: true,
        title: "Schedule Zoom Meeting",
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

            _FormCard(
              title: "Meeting Information",
              subtitle: "Client and agenda details",
              children: [
                if (widget.clientId == null) ...[
                  _ClientPicker(
                    selectedId: _selectedClientId,
                    onSelected: (id, name) {
                      setState(() {
                        _selectedClientId = id;
                        _selectedClientName = name;
                        if (_topicController.text.isEmpty) _topicController.text = "Consultation with $name";
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Client", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                              Text(widget.clientName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    labelText: "Meeting Topic *",
                    hintText: "e.g., Initial Strategy Session",
                    prefixIcon: Icon(Icons.videocam_outlined),
                  ),
                  validator: (v) => Validators.required(v, field: "Topic"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _FormCard(
              title: "Date & Time",
              subtitle: "When should the Zoom call start?",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DateTimeCard(
                        icon: Icons.calendar_today_rounded,
                        label: "Date",
                        value: _date == null
                            ? "Select Date"
                            : "${_date!.year}-${_date!.month.toString().padLeft(2, "0")}-${_date!.day.toString().padLeft(2, "0")}",
                        isSelected: _date != null,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTimeCard(
                        icon: Icons.access_time_rounded,
                        label: "Time",
                        value: _time == null ? "Select Time" : _time!.format(context),
                        isSelected: _time != null,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "Duration",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.meetingDurations.map((d) {
                    final selected = _duration == d;
                    return ChoiceChip(
                      label: Text("$d minutes"),
                      selected: selected,
                      selectedColor: const Color(0xFF2563EB).withOpacity(0.12),
                      labelStyle: TextStyle(
                        color: selected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (_) => setState(() => _duration = d),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            CustomButton(
              label: "Schedule Zoom Meeting",
              icon: Icons.video_call_rounded,
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

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.subtitle, required this.children});

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

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientPicker extends ConsumerWidget {
  const _ClientPicker({required this.selectedId, required this.onSelected});
  final String? selectedId;
  final void Function(String id, String name) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientListProvider);
    return clientsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text("Could not load clients: $e"),
      data: (result) {
        final isValid = selectedId != null && result.data.any((c) => c.id == selectedId);
        return DropdownButtonFormField<String>(
          initialValue: isValid ? selectedId : null,
          decoration: const InputDecoration(
            labelText: "Select Client *",
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          items: result.data
              .map<DropdownMenuItem<String>>(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.fullName)),
              )
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final client = result.data.firstWhere((c) => c.id == id);
            onSelected(id, client.fullName);
          },
        );
      },
    );
  }
}
