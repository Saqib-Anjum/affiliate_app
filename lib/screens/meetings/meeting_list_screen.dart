import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/meeting_provider.dart";
import "../../widgets/meeting_card.dart";
import "book_meeting_screen.dart";

class MeetingListScreen extends ConsumerStatefulWidget {
  const MeetingListScreen({super.key});

  @override
  ConsumerState<MeetingListScreen> createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends ConsumerState<MeetingListScreen> {
  bool _upcomingOnly = true;

  @override
  Widget build(BuildContext context) {
    final meetingsAsync = _upcomingOnly ? ref.watch(upcomingMeetingsProvider) : ref.watch(allMeetingsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "meeting_fab",
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookMeetingScreen())),
        icon: const Icon(Icons.add),
        label: const Text("Book Meeting"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text("Upcoming")),
                ButtonSegment(value: false, label: Text("All")),
              ],
              selected: {_upcomingOnly},
              onSelectionChanged: (s) => setState(() => _upcomingOnly = s.first),
            ),
          ),
          Expanded(
            child: meetingsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (result) {
                if (result.data.isEmpty) {
                  return const EmptyState(title: "No meetings found", icon: Icons.event_busy_outlined);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: result.data.length,
                  itemBuilder: (context, index) {
                    final meeting = result.data[index];
                    return MeetingCard(
                      meeting: meeting,
                      onJoin: meeting.zoomJoinUrl != null
                          ? () => launchUrl(Uri.parse(meeting.zoomJoinUrl!))
                          : null,
                      onCancel: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Cancel Meeting?"),
                            content: Text("Are you sure you want to cancel '${meeting.topic}'?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text("Yes, Cancel"),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            await ref.read(meetingActionsProvider).cancel(meeting.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Meeting cancelled successfully")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Failed to cancel meeting: $e")),
                              );
                            }
                          }
                        }
                      },
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
