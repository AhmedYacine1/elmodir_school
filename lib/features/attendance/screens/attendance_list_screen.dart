import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../../../models/attendance.dart';
import '../../../models/student.dart';
import '../../../core/database/isar_service.dart';
import '../../students/providers/student_provider.dart';
import '../widgets/attendance_form_dialog.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  List<Attendance> filteredAttendance = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredAttendance = ref.read(attendanceProvider);
  }

  void _runFilter(String query) {
    final attendanceRecords = ref.read(attendanceProvider);
    setState(() {
      if (query.isEmpty) {
        filteredAttendance = attendanceRecords;
      } else {
        filteredAttendance = attendanceRecords.where((attendance) =>
            _getStudentName(attendance.studentId, ref).toLowerCase().contains(query.toLowerCase()) ||
            attendance.date.toString().toLowerCase().contains(query.toLowerCase()) ||
            attendance.status.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(attendanceProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الحضور'),
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
                    return ListView.builder(
                      itemCount: filteredAttendance.length,
                      itemBuilder: (context, index) {
                        final attendance = filteredAttendance[index];
                        return Card(
                          child: ListTile(
                            title: Text(_getStudentName(attendance.studentId, ref)),
                            subtitle: Text(
                              'التاريخ: ${attendance.date.toString().split(' ')[0]} | '
                              'الحالة: ${attendance.status}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showAttendanceFormDialog(context, attendance, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, attendance.id!, ref),
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
          onPressed: () => _showAttendanceFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _getStudentName(int studentId, WidgetRef ref) {
    final students = ref.read(studentProvider);
    final student = students.firstWhere((element) => element.id == studentId, orElse: () => Student(firstName: 'غير معروف', lastName: '', birthDate: DateTime.now(), gender: '', registrationNumber: '', isActive: true));
    return '${student.firstName} ${student.lastName}';
  }

  Future<void> _showAttendanceFormDialog(BuildContext context, Attendance? attendance, WidgetRef ref) async {
    final students = ref.read(studentProvider);

    await showDialog(
      context: context,
      builder: (context) => AttendanceFormDialog(
        attendance: attendance,
        students: students,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا التسجيل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(attendanceProvider.notifier).deleteAttendance(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}