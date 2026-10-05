import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";
import "../../core/widgets/search_field.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/recording_provider.dart";
import "../../widgets/recording_card.dart";

/// "Client Meeting Recordings" screen with client-side search.
class RecordingsScreen extends ConsumerStatefulWidget {
  const RecordingsScreen({super.key});

  @override
  ConsumerState<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends ConsumerState<RecordingsScreen> {
  String _search = "";

  @override
  Widget build(BuildContext context) {
    final recordingsAsync = ref.watch(recordingsProvider);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(hintText: "Search recordings…", onChanged: (v) => setState(() => _search = v)),
          ),
          Expanded(
            child: recordingsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (result) {
                final filtered = _search.isEmpty
                    ? result.data
                    : result.data
                        .where((r) => (r.meetingTopic ?? r.meetingId).toLowerCase().contains(_search.toLowerCase()))
                        .toList();
                if (filtered.isEmpty) {
                  return const EmptyState(
                    title: "No recordings yet",
                    description: "Recordings appear automatically after a Zoom meeting ends.",
                    icon: Icons.videocam_off_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recording = filtered[index];
                    return RecordingCard(
                      recording: recording,
                      onWatch: () => launchUrl(Uri.parse(recording.recordingUrl)),
                      onDownload: recording.downloadUrl != null
                          ? () => launchUrl(Uri.parse(recording.downloadUrl!))
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
