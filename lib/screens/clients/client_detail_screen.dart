import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";
import "../../core/constants/app_constants.dart";
import "../../core/utils/formatters.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/auth_provider.dart";
import "../../providers/client_provider.dart";
import "../../providers/recording_provider.dart";
import "../../widgets/app_header.dart";
import "../../widgets/client_status_badge.dart";
import "../../widgets/quote_share_sheet.dart";
import "../../widgets/recording_card.dart";
import "../meetings/book_meeting_screen.dart";
import "client_form_screen.dart";

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});
  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsync = ref.watch(clientDetailProvider(clientId));
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppHeader(
        showBackButton: true,
        title: "Client Details",
        actions: [
          clientAsync.maybeWhen(
            data: (client) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ClientFormScreen(existing: client)),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: clientAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (client) {
          final recordingsAsync = ref.watch(clientRecordingsProvider(clientId));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(client.fullName, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(width: 8),
                  ClientStatusBadge(status: client.status),
                ],
              ),
              if (client.emergencyMeeting) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text("This client is marked as an emergency. Prioritize scheduling."),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              if (isAdmin)
                _Section(
                  title: "Update Status",
                  child: Wrap(
                    spacing: 8,
                    children: AppConstants.clientStatuses.map((status) {
                      final selected = client.status == status;
                      return ChoiceChip(
                        label: Text(AppConstants.clientStatusLabels[status]!),
                        selected: selected,
                        onSelected: (_) async {
                          await ref.read(clientActionsProvider).updateStatus(client.id, status);
                          ref.invalidate(clientDetailProvider(clientId));
                        },
                      );
                    }).toList(),
                  ),
                ),

              _Section(
                title: "Contact Information",
                child: Column(
                  children: [
                    _Row(label: "Phone", value: client.phoneNumber),
                    _Row(label: "Email", value: client.email),
                    _Row(label: "Website", value: client.website, isLink: true),
                    _Row(label: "Business Niche", value: client.businessNiche),
                  ],
                ),
              ),

              _Section(
                title: "Quote & Pricing",
                trailing: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.ios_share_outlined, size: 16),
                  label: const Text("Share Quote"),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => QuoteShareSheet(client: client),
                  ),
                ),
                child: Column(
                  children: [
                    _Row(label: "Quote Amount", value: Formatters.currency(client.quoteAmount, code: client.currency)),
                    _Row(label: "Discount", value: Formatters.currency(client.discount, code: client.currency)),
                    _Row(label: "Final Price", value: Formatters.currency(client.finalPrice, code: client.currency)),
                    if (isAdmin) ...[
                      _Row(
                        label: "Sale Amount",
                        value: Formatters.currency(client.saleAmount ?? (client.isClosedSale ? client.finalPrice : null), code: client.currency),
                      ),
                      _Row(
                        label: "Student Revenue",
                        value: Formatters.currency(client.studentRevenue, code: client.currency),
                      ),
                    ],
                  ],
                ),
              ),

              _Section(
                title: "Meeting",
                trailing: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: const Text("Book Meeting"),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BookMeetingScreen(clientId: client.id, clientName: client.fullName)),
                  ),
                ),
                child: client.meetingDate == null
                    ? Text("No meeting scheduled yet.", style: Theme.of(context).textTheme.bodySmall)
                    : Column(
                        children: [
                          _Row(label: "Date", value: Formatters.date(client.meetingDate)),
                          _Row(label: "Time", value: client.meetingTime),
                          if (client.zoomJoinUrl != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                icon: const Icon(Icons.videocam_outlined),
                                label: const Text("Join Zoom Meeting"),
                                onPressed: () => launchUrl(Uri.parse(client.zoomJoinUrl!)),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),

              if (client.notes != null && client.notes!.isNotEmpty)
                _Section(title: "Notes", child: Text(client.notes!)),

              _Section(
                title: "Recordings",
                child: recordingsAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Text("Could not load recordings", style: TextStyle(color: Colors.red.shade600)),
                  data: (recordings) {
                    if (recordings.isEmpty) {
                      return Text("No recordings yet.", style: Theme.of(context).textTheme.bodySmall);
                    }
                    return Column(
                      children: recordings
                          .map((r) => RecordingCard(recording: r, onWatch: () => launchUrl(Uri.parse(r.recordingUrl))))
                          .toList(),
                    );
                  },
                ),
              ),

              if (isAdmin) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                  label: Text("Delete Client", style: TextStyle(color: Colors.red.shade600)),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete client?"),
                        content: const Text("This cannot be undone."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(clientActionsProvider).delete(client.id);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, this.value, this.isLink = false});
  final String label;
  final String? value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    final display = (value == null || value!.isEmpty) ? "—" : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: GestureDetector(
              onTap: isLink && value != null && value!.isNotEmpty
                  ? () => launchUrl(Uri.parse(value!.startsWith("http") ? value! : "https://$value"))
                  : null,
              child: Text(
                display,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isLink ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
                  decoration: isLink ? TextDecoration.underline : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
