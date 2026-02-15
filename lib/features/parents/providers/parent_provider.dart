import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/parent.dart';

final parentProvider = StateNotifierProvider<ParentNotifier, List<Parent>>(
  (ref) => ParentNotifier(),
);

final selectedParentProvider = StateProvider<Parent?>((ref) => null);

class ParentNotifier extends StateNotifier<List<Parent>> {
  ParentNotifier() : super([]) {
    loadParents();
  }

  Future<void> loadParents() async {
    state = await IsarService.getAllParents();
  }

  Future<void> addParent(Parent parent) async {
    final id = await IsarService.putParent(parent);
    await loadParents();
  }

  Future<void> updateParent(Parent parent) async {
    await IsarService.putParent(parent);
    await loadParents();
  }

  Future<void> deleteParent(int id) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.parents.delete(id);
    });
    await loadParents();
  }
}