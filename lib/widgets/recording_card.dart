import "package:flutter/material.dart";
import "../core/utils/formatters.dart";
import "../models/recording_model.dart";

class RecordingCard extends StatelessWidget {
  const RecordingCard({super.key, required this.recording, required this.onWatch, this.onDownload});
  final RecordingModel recording;
  final VoidCallback onWatch;
  final VoidCallback? onDownload;

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
                const Icon(Icons.videocam_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recording.meetingTopic ?? "Meeting ${recording.meetingId}",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "${Formatters.date(recording.recordingDate)} • ${Formatters.duration(recording.duration)}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onWatch,
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: const Text("Watch"),
                  ),
                ),
                if (onDownload != null) ...[
                  const SizedBox(width: 8),
                  IconButton(onPressed: onDownload, icon: const Icon(Icons.download_outlined)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
