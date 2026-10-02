import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/client_model.dart";
import "../services/api_client.dart";
import "dashboard_provider.dart";
import "service_providers.dart";

class ClientFilters {
  const ClientFilters({this.search = "", this.status = "", this.businessNiche = "", this.emergency});
  final String search;
  final String status;
  final String businessNiche;
  final bool? emergency;

  ClientFilters copyWith({String? search, String? status, String? businessNiche, bool? emergency}) {
    return ClientFilters(
      search: search ?? this.search,
      status: status ?? this.status,
      businessNiche: businessNiche ?? this.businessNiche,
      emergency: emergency ?? this.emergency,
    );
  }
}

final clientFiltersProvider = StateProvider<ClientFilters>((ref) => const ClientFilters());
final clientPageProvider = StateProvider<int>((ref) => 1);

final clientListProvider = FutureProvider<Paginated<ClientModel>>((ref) async {
  final filters = ref.watch(clientFiltersProvider);
  final page = ref.watch(clientPageProvider);
  ref.watch(dashboardRefreshProvider); // also refetch list after mutations
  return ref.watch(clientServiceProvider).list(
        page: page,
        search: filters.search,
        status: filters.status,
        businessNiche: filters.businessNiche,
        emergency: filters.emergency,
      );
});

final clientDetailProvider = FutureProvider.family<ClientModel, String>((ref, id) async {
  ref.watch(dashboardRefreshProvider);
  return ref.watch(clientServiceProvider).getOne(id);
});

class ClientActions {
  ClientActions(this._ref);
  final Ref _ref;

  Future<ClientModel> create(ClientModel client) async {
    final created = await _ref.read(clientServiceProvider).create(client);
    _bump();
    return created;
  }

  Future<ClientModel> update(String id, Map<String, dynamic> patch) async {
    final updated = await _ref.read(clientServiceProvider).update(id, patch);
    _bump();
    return updated;
  }

  Future<ClientModel> updateStatus(String id, String status) async {
    final updated = await _ref.read(clientServiceProvider).updateStatus(id, status);
    _bump();
    return updated;
  }

  Future<void> delete(String id) async {
    await _ref.read(clientServiceProvider).delete(id);
    _bump();
  }

  void _bump() => _ref.read(dashboardRefreshProvider.notifier).state++;
}

final clientActionsProvider = Provider((ref) => ClientActions(ref));
