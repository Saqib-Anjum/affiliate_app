import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fl_chart/fl_chart.dart";
import "../../core/theme/app_theme.dart";
import "../../core/utils/formatters.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/dashboard_provider.dart";
import "../../services/api_client.dart";
import "../../widgets/stat_card.dart";

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final revenueByStudentAsync = ref.watch(adminRevenueByStudentProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(adminRevenueByStudentProvider);
          try {
            await ref.read(dashboardStatsProvider.future);
          } catch (_) {}
        },
        child: statsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorStateWidget(
            message: e.toString(),
            onRetry: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(adminRevenueByStudentProvider);
            },
          ),
          data: (stats) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text("System-wide statistics", style: textTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(label: "Total Students", value: "${stats.totalStudents ?? 0}", icon: Icons.school_outlined),
                    StatCard(label: "Total Clients", value: "${stats.totalClients}", icon: Icons.people_outline),
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
                      label: "Student Revenue (Payout)",
                      value: Formatters.currency(stats.payout),
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.pending,
                    ),
                    StatCard(
                      label: "Emergency Meetings",
                      value: "${stats.emergencyMeetings}",
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.emergency,
                    ),
                    StatCard(label: "Upcoming Meetings", value: "${stats.upcomingMeetings}", icon: Icons.event_outlined),
                    StatCard(label: "Recordings", value: "${stats.totalRecordings ?? 0}", icon: Icons.videocam_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                Text("Revenue by Student", style: textTheme.titleMedium),
                const SizedBox(height: 12),
                revenueByStudentAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (e, _) => ErrorStateWidget(message: e.toString()),
                  data: (rows) {
                    if (rows.isEmpty) {
                      return const EmptyState(title: "No revenue yet", icon: Icons.bar_chart_outlined);
                    }
                    return SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            for (int i = 0; i < rows.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: parseDouble(rows[i]["revenue"]),
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 18,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= rows.length) return const SizedBox.shrink();
                                  final name = (rows[index]["studentName"] ?? "").toString();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      name.length > 8 ? "${name.substring(0, 8)}…" : name,
                                      style: textTheme.bodySmall?.copyWith(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
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
