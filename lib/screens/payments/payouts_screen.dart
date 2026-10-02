import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/theme/app_theme.dart";
import "../../core/utils/formatters.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/payment_provider.dart";

class PayoutsScreen extends ConsumerWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(payoutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Payout History")),
      body: payoutsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (result) {
          if (result.data.isEmpty) {
            return const EmptyState(title: "No payouts yet", icon: Icons.account_balance_wallet_outlined);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.data.length,
            itemBuilder: (context, index) {
              final payout = result.data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.attach_money, color: AppColors.primary),
                  ),
                  title: Text(Formatters.currency(payout.amount)),
                  subtitle: Text(Formatters.date(payout.createdAt)),
                  trailing: Chip(label: Text(Formatters.statusLabel(payout.status))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
