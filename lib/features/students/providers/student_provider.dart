import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/student.dart';

final studentProvider = StateNotifierProvider<StudentNotifier, List<Student>>(
  (ref) => StudentNotifier(),
);

final selectedStudentProvider = StateProvider<Student?>((ref) => null);

class StudentNotifier extends StateNotifier<List<Student>> {
  StudentNotifier() : super([]) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = await IsarService.getAllStudents();
  }

  Future<void> addStudent(Student student) async {
    final id = await IsarService.putStudent(student);
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    await IsarService.putStudent(student);
    await loadStudents();
  }

  Future<void> deleteStudent(int id) async {
    await IsarService.deleteStudent(id);
    await loadStudents();
  }
}