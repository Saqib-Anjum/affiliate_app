import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../providers/auth_provider.dart";
import "../clients/client_list_screen.dart";
import "../dashboard/admin_dashboard_screen.dart";
import "../dashboard/student_dashboard_screen.dart";
import "../meetings/meeting_list_screen.dart";
import "../profile/profile_screen.dart";
import "../recordings/recordings_screen.dart";
import "../students/student_list_screen.dart";

/// Bottom navigation shell. Spec section 20:
///   Student -> Dashboard, Clients, Meetings, Recordings, Profile
///   Admin   -> Dashboard, Clients, Students, Meetings, Recordings, Profile
/// (Admin's Payments/Payouts/Settings pages are reachable from the dashboard
/// and profile menus to keep the bottom bar within a comfortable item count.)
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    final destinations = <_ShellDestination>[
      _ShellDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        label: "Dashboard",
        screen: isAdmin ? const AdminDashboardScreen() : const StudentDashboardScreen(),
      ),
      const _ShellDestination(
        icon: Icons.people_outline,
        selectedIcon: Icons.people,
        label: "Clients",
        screen: ClientListScreen(),
      ),
      if (isAdmin)
        const _ShellDestination(
          icon: Icons.school_outlined,
          selectedIcon: Icons.school,
          label: "Students",
          screen: StudentListScreen(),
        ),
      const _ShellDestination(
        icon: Icons.event_outlined,
        selectedIcon: Icons.event,
        label: "Meetings",
        screen: MeetingListScreen(),
      ),
      const _ShellDestination(
        icon: Icons.videocam_outlined,
        selectedIcon: Icons.videocam,
        label: "Recordings",
        screen: RecordingsScreen(),
      ),
      const _ShellDestination(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: "Profile",
        screen: ProfileScreen(),
      ),
    ];

    final safeIndex = _index < destinations.length ? _index : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: destinations.map((d) => d.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations
            .map((d) => NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label))
            .toList(),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;
}
