import "package:flutter/material.dart";
import "../core/utils/formatters.dart";
import "../models/client_model.dart";
import "client_status_badge.dart";

class ClientCard extends StatelessWidget {
  const ClientCard({super.key, required this.client, required this.onTap});
  final ClientModel client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      client.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (client.emergencyMeeting) ...[const EmergencyBadge(), const SizedBox(width: 6)],
                  ClientStatusBadge(status: client.status),
                ],
              ),
              const SizedBox(height: 6),
              if (client.businessNiche != null)
                Text(client.businessNiche!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(client.phoneNumber ?? "—", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 14, color: Colors.grey.shade500),
                  Text(
                    client.isClosedSale ? Formatters.currency(client.saleAmount) : "—",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
