import "package:flutter/material.dart";
import "../core/constants/app_constants.dart";
import "../core/theme/app_theme.dart";

class ClientStatusBadge extends StatelessWidget {
  const ClientStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forClientStatus(status);
    final label = AppConstants.clientStatusLabels[status] ?? status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class EmergencyBadge extends StatelessWidget {
  const EmergencyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.emergency.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.emergency.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.emergency),
          const SizedBox(width: 4),
          Text("Emergency", style: TextStyle(color: AppColors.emergency, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
