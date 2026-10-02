import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:share_plus/share_plus.dart";
import "package:url_launcher/url_launcher.dart";
import "../core/utils/formatters.dart";
import "../models/client_model.dart";

/// Spec section 8/27: generates a professional quote message and offers
/// WhatsApp / SMS / Email / copy-to-clipboard sharing. PDF export is not
/// implemented yet -- see README "Not yet built".
class QuoteShareSheet extends StatelessWidget {
  const QuoteShareSheet({super.key, required this.client});
  final ClientModel client;

  String _buildMessage() {
    final buffer = StringBuffer();
    buffer.writeln("Client: ${client.fullName}");
    if (client.businessNiche != null) buffer.writeln("Business: ${client.businessNiche}");
    buffer.writeln("Quote: ${Formatters.currency(client.quoteAmount, code: client.currency)}");
    if ((client.discount ?? 0) > 0) {
      buffer.writeln("Discount: ${Formatters.currency(client.discount, code: client.currency)}");
      buffer.writeln("Final Price: ${Formatters.currency(client.finalPrice, code: client.currency)}");
    }
    if (client.notes != null && client.notes!.isNotEmpty) {
      buffer.writeln("Notes: ${client.notes}");
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final message = _buildMessage();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Share Quote", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ShareAction(
                  icon: Icons.chat_bubble_outline,
                  label: "WhatsApp",
                  onTap: () => launchUrl(Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}")),
                ),
                _ShareAction(
                  icon: Icons.email_outlined,
                  label: "Email",
                  onTap: () => launchUrl(
                    Uri(scheme: "mailto", queryParameters: {"subject": "Your Quote", "body": message}),
                  ),
                ),
                _ShareAction(
                  icon: Icons.sms_outlined,
                  label: "SMS",
                  onTap: () => launchUrl(Uri(scheme: "sms", queryParameters: {"body": message})),
                ),
                _ShareAction(
                  icon: Icons.ios_share_outlined,
                  label: "Share",
                  onTap: () => Share.share(message),
                ),
                _ShareAction(
                  icon: Icons.copy_outlined,
                  label: "Copy",
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quote copied to clipboard")),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label));
  }
}
