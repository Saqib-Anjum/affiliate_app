import "package:flutter/material.dart";
import "../core/theme/app_theme.dart";
import "../core/utils/formatters.dart";
import "../models/meeting_model.dart";

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key, required this.meeting, this.onJoin, this.onCancel});
  final MeetingModel meeting;
  final VoidCallback? onJoin;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(meeting.topic, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                if (meeting.emergency)
                  Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.emergency),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(Formatters.dateTime(meeting.startTime), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text("${meeting.durationMinutes} minutes • ${meeting.timezone}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            if (onJoin != null || onCancel != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (onJoin != null && meeting.zoomJoinUrl != null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onJoin,
                        icon: const Icon(Icons.videocam_outlined, size: 18),
                        label: const Text("Join Meeting"),
                      ),
                    ),
                  if (onCancel != null && meeting.status == "scheduled") ...[
                    const SizedBox(width: 8),
                    TextButton(onPressed: onCancel, child: const Text("Cancel")),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
