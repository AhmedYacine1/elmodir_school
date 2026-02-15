import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
import '../../../models/student.dart';
import '../../../models/parent.dart';
import '../../../models/class.dart';
import '../../../core/database/isar_service.dart';
import '../../parents/providers/parent_provider.dart';
import '../../classes/providers/class_provider.dart';
import '../widgets/student_form_dialog.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  List<Student> filteredStudents = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredStudents = ref.read(studentProvider);
  }

  void _runFilter(String query) {
    final students = ref.read(studentProvider);
    setState(() {
      if (query.isEmpty) {
        filteredStudents = students;
      } else {
        filteredStudents = students.where((student) =>
            student.firstName.toLowerCase().contains(query.toLowerCase()) ||
            student.lastName.toLowerCase().contains(query.toLowerCase()) ||
            student.registrationNumber.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(studentProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الطلاب'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'بحث',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  _runFilter(value);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final students = ref.watch(studentProvider);
                    return ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        return Card(
                          child: ListTile(
                            title: Text('${student.firstName} ${student.lastName}'),
                            subtitle: Text(
                              'الرقم: ${student.registrationNumber} | '
                              'الصف: ${_getClassName(student.classId, ref)} | '
                              'الحالة: ${student.isActive ? 'نشط' : 'غير نشط'}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showStudentFormDialog(context, student, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, student.id!, ref),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showStudentFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _getClassName(int? classId, WidgetRef ref) {
    if (classId == null) return 'غير محدد';
    final classes = ref.read(classProvider);
    final classModel = classes.firstWhere((element) => element.id == classId, orElse: () => ClassModel(name: 'غير محدد', capacity: 0, shift: ''));
    return classModel.name;
  }

  Future<void> _showStudentFormDialog(BuildContext context, Student? student, WidgetRef ref) async {
    final parents = ref.read(parentProvider);
    final classes = ref.read(classProvider);

    await showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        student: student,
        parents: parents,
        classes: classes,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الطالب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(studentProvider.notifier).deleteStudent(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}