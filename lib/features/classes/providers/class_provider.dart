import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/class.dart';

final classProvider = StateNotifierProvider<ClassNotifier, List<ClassModel>>(
  (ref) => ClassNotifier(),
);

final selectedClassProvider = StateProvider<ClassModel?>((ref) => null);

class ClassNotifier extends StateNotifier<List<ClassModel>> {
  ClassNotifier() : super([]) {
    loadClasses();
  }

  Future<void> loadClasses() async {
    state = await IsarService.getAllClasses();
  }

  Future<void> addClass(ClassModel classModel) async {
    final id = await IsarService.putClass(classModel);
    await loadClasses();
  }

  Future<void> updateClass(ClassModel classModel) async {
    await IsarService.putClass(classModel);
    await loadClasses();
  }

  Future<void> deleteClass(int id) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.classes.delete(id);
    });
    await loadClasses();
  }
}