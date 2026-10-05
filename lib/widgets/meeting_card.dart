import "package:flutter/material.dart";
import "../core/theme/app_theme.dart";
import "../core/utils/formatters.dart";
import "../models/meeting_model.dart";

class MeetingCard extends StatelessWidget {
  const MeetingCard({super.key, required this.meeting, this.onJoin, this.onCancel});
  final MeetingModel meeting;
  final VoidCallback? onJoin;
  final VoidCallback? onCancel;

  bool get _canCancel => onCancel != null && meeting.status.toLowerCase() != "cancelled";

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  child: Text(
                    meeting.topic,
                    style: textTheme.titleSmall ?? const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                if (meeting.emergency)
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.emergency),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: textTheme.bodySmall?.color),
                const SizedBox(width: 6),
                Text(Formatters.dateTime(meeting.startTime), style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: textTheme.bodySmall?.color),
                const SizedBox(width: 6),
                Text("${meeting.durationMinutes} minutes • ${meeting.timezone}", style: textTheme.bodySmall),
              ],
            ),
            if (onJoin != null || _canCancel) ...[
              const SizedBox(height: 12),
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
                  if (_canCancel) ...[
                    if (onJoin != null && meeting.zoomJoinUrl != null) const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.emergency,
                        side: const BorderSide(color: AppColors.emergency),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text("Cancel Meeting"),
                    ),
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
