import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/user_model.dart";
import "../services/api_client.dart";
import "service_providers.dart";

final studentSearchProvider = StateProvider<String>((ref) => "");
final studentsRefreshProvider = StateProvider<int>((ref) => 0);

final studentsProvider = FutureProvider<Paginated<UserModel>>((ref) async {
  ref.watch(studentsRefreshProvider);
  final search = ref.watch(studentSearchProvider);
  return ref.watch(studentServiceProvider).list(limit: 50, search: search);
});

class StudentActions {
  StudentActions(this._ref);
  final Ref _ref;

  Future<void> create({required String fullName, required String email, String? phone, required String password}) async {
    await _ref.read(studentServiceProvider).create(fullName: fullName, email: email, phone: phone, password: password);
    _bump();
  }

  Future<void> setActive(String id, bool isActive) async {
    await _ref.read(studentServiceProvider).setActive(id, isActive);
    _bump();
  }

  void _bump() => _ref.read(studentsRefreshProvider.notifier).state++;
}

final studentActionsProvider = Provider((ref) => StudentActions(ref));
