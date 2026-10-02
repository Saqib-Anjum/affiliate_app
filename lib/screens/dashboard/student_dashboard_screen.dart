import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fl_chart/fl_chart.dart";
import "../../core/theme/app_theme.dart";
import "../../core/utils/formatters.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/auth_provider.dart";
import "../../providers/dashboard_provider.dart";
import "../../providers/meeting_provider.dart";
import "../../widgets/meeting_card.dart";
import "../../widgets/stat_card.dart";
import "../meetings/book_meeting_screen.dart";

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final user = ref.watch(authProvider).user;
    final upcomingAsync = ref.watch(upcomingMeetingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(dashboardRefreshProvider.notifier).state++,
        child: statsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorStateWidget(
            message: e.toString(),
            onRetry: () => ref.read(dashboardRefreshProvider.notifier).state++,
          ),
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("Welcome back, ${user?.fullName ?? "Student"}", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text("Here is how your clients are performing.", style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      label: "Total Clients",
                      value: "${stats.totalClients}",
                      icon: Icons.people_outline,
                    ),
                    StatCard(
                      label: "Closed Sales",
                      value: "${stats.closedSales}",
                      icon: Icons.trending_up,
                      color: AppColors.signup,
                    ),
                    StatCard(
                      label: "Total Revenue",
                      value: Formatters.currency(stats.totalRevenue),
                      icon: Icons.attach_money,
                      color: AppColors.signup,
                    ),
                    StatCard(
                      label: "Payout",
                      value: Formatters.currency(stats.payout),
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.pending,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Client Status", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: [
                              PieChartSectionData(
                                value: stats.pendingClients.toDouble(),
                                color: AppColors.pending,
                                title: "${stats.pendingClients}",
                                radius: 46,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                value: stats.signupClients.toDouble(),
                                color: AppColors.signup,
                                title: "${stats.signupClients}",
                                radius: 46,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                value: stats.notInterestedClients.toDouble(),
                                color: AppColors.notInterested,
                                title: "${stats.notInterestedClients}",
                                radius: 46,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _Legend(color: AppColors.pending, label: "Pending"),
                            _Legend(color: AppColors.signup, label: "Signup"),
                            _Legend(color: AppColors.notInterested, label: "Not Interested"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Upcoming Meetings", style: Theme.of(context).textTheme.titleMedium),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BookMeetingScreen()),
                      ),
                      child: const Text("Book Meeting"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                upcomingAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (e, _) => ErrorStateWidget(message: e.toString()),
                  data: (meetings) {
                    if (meetings.data.isEmpty) {
                      return const EmptyState(title: "No upcoming meetings", icon: Icons.event_available_outlined);
                    }
                    return Column(
                      children: meetings.data
                          .take(3)
                          .map((m) => MeetingCard(meeting: m, onJoin: () {}))
                          .toList(),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
