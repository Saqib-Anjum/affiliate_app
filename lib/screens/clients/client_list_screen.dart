import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/constants/app_constants.dart";
import "../../core/widgets/search_field.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/client_provider.dart";
import "../../widgets/client_card.dart";
import "client_detail_screen.dart";
import "client_form_screen.dart";

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientListProvider);
    final filters = ref.watch(clientFiltersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "client_fab",
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClientFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text("Add Client"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchField(
              hintText: "Search by name, phone, email, website…",
              onChanged: (value) {
                ref.read(clientFiltersProvider.notifier).state = filters.copyWith(search: value);
                ref.read(clientPageProvider.notifier).state = 1;
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _StatusChip(
                  label: "All",
                  selected: filters.status.isEmpty,
                  onTap: () => ref.read(clientFiltersProvider.notifier).state = filters.copyWith(status: ""),
                ),
                for (final status in AppConstants.clientStatuses)
                  _StatusChip(
                    label: AppConstants.clientStatusLabels[status]!,
                    selected: filters.status == status,
                    onTap: () => ref.read(clientFiltersProvider.notifier).state = filters.copyWith(status: status),
                  ),
                _StatusChip(
                  label: "🚨 Emergency",
                  selected: filters.emergency == true,
                  onTap: () => ref.read(clientFiltersProvider.notifier).state =
                      filters.copyWith(emergency: filters.emergency == true ? null : true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: clientsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (result) {
                if (result.data.isEmpty) {
                  return const EmptyState(
                    title: "No clients found",
                    description: "Try a different search or add your first client.",
                    icon: Icons.person_search_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(clientListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: result.data.length,
                    itemBuilder: (context, index) {
                      final client = result.data[index];
                      return ClientCard(
                        client: client,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ClientDetailScreen(clientId: client.id)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}
