import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../providers/auth_provider.dart";

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                (user?.fullName.isNotEmpty == true ? user!.fullName[0] : "?").toUpperCase(),
                style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user?.fullName ?? "", style: Theme.of(context).textTheme.titleLarge)),
          Center(
            child: Text(
              (user?.role ?? "").toUpperCase(),
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.email_outlined), title: const Text("Email"), subtitle: Text(user?.email ?? "—")),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.phone_outlined), title: const Text("Phone"), subtitle: Text(user?.phone ?? "—")),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade600),
          ),
        ],
      ),
    );
  }
}
