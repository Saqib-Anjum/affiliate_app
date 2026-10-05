import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../providers/auth_provider.dart";
import "../../providers/theme_provider.dart";

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              child: Text(
                (user?.fullName.isNotEmpty == true ? user!.fullName[0] : "?").toUpperCase(),
                style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user?.fullName ?? "", style: textTheme.titleLarge)),
          Center(
            child: Text(
              (user?.role ?? "").toUpperCase(),
              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text("Email"),
                  subtitle: Text(user?.email ?? "—", style: textTheme.bodyMedium),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text("Phone"),
                  subtitle: Text(user?.phone ?? "—", style: textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text("App Theme Preference", style: textTheme.titleSmall),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_auto_rounded),
                  title: const Text("System Default"),
                  trailing: themeMode == ThemeMode.system ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.light_mode_rounded),
                  title: const Text("Light Mode"),
                  trailing: themeMode == ThemeMode.light ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_rounded),
                  title: const Text("Dark Mode"),
                  trailing: themeMode == ThemeMode.dark ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary) : null,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
