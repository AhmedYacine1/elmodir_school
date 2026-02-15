import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/staff.dart';

final staffProvider = StateNotifierProvider<StaffNotifier, List<Staff>>(
  (ref) => StaffNotifier(),
);

final selectedStaffProvider = StateProvider<Staff?>((ref) => null);

class StaffNotifier extends StateNotifier<List<Staff>> {
  StaffNotifier() : super([]) {
    loadStaff();
  }

  Future<void> loadStaff() async {
    state = await IsarService.getAllStaff();
  }

  Future<void> addStaff(Staff staff) async {
    final id = await IsarService.putStaff(staff);
    await loadStaff();
  }

  Future<void> updateStaff(Staff staff) async {
    await IsarService.putStaff(staff);
    await loadStaff();
  }

  Future<void> deleteStaff(int id) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.staffs.delete(id);
    });
    await loadStaff();
  }
}