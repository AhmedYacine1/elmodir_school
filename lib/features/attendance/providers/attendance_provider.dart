import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/attendance.dart';

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, List<Attendance>>(
  (ref) => AttendanceNotifier(),
);

final selectedAttendanceProvider = StateProvider<Attendance?>((ref) => null);

class AttendanceNotifier extends StateNotifier<List<Attendance>> {
  AttendanceNotifier() : super([]) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    state = await IsarService.getAllAttendance();
  }

  Future<void> addAttendance(Attendance attendance) async {
    final id = await IsarService.putAttendance(attendance);
    await loadAttendance();
  }

  Future<void> updateAttendance(Attendance attendance) async {
    await IsarService.putAttendance(attendance);
    await loadAttendance();
  }

  Future<void> deleteAttendance(int id) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.attendances.delete(id);
    });
    await loadAttendance();
  }
}