import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../../../models/attendance.dart';
import '../../../models/student.dart';

class AttendanceFormDialog extends ConsumerStatefulWidget {
  final Attendance? attendance;
  final List<Student> students;

  const AttendanceFormDialog({
    Key? key,
    this.attendance,
    required this.students,
  }) : super(key: key);

  @override
  ConsumerState<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends ConsumerState<AttendanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  int? _selectedStudentId;
  String _status = '';

  @override
  void initState() {
    super.initState();
    if (widget.attendance != null) {
      final attendance = widget.attendance!;
      _dateController.text = attendance.date.toString().split(' ')[0];
      _selectedStudentId = attendance.studentId;
      _status = attendance.status;
    } else {
      _dateController.text = DateTime.now().toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.attendance == null ? 'تسجيل الحضور' : 'تعديل الحضور'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'التاريخ'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.attendance?.date ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _dateController.text = date.toString().split(' ')[0];
                      });
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _selectedStudentId,
                  decoration: const InputDecoration(labelText: 'الطالب'),
                  items: widget.students.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text('${student.firstName} ${student.lastName}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'الرجاء اختيار الطالب';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status.isEmpty ? null : _status,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: const [
                    DropdownMenuItem(value: 'present', child: Text('حاضر')),
                    DropdownMenuItem(value: 'absent', child: Text('غائب')),
                    DropdownMenuItem(value: 'justified', child: Text('غائب مبرر')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الحالة';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final attendance = Attendance(
                id: widget.attendance?.id,
                studentId: _selectedStudentId!,
                date: DateTime.parse(_dateController.text),
                status: _status,
              );

              if (widget.attendance == null) {
                await ref.read(attendanceProvider.notifier).addAttendance(attendance);
              } else {
                await ref.read(attendanceProvider.notifier).updateAttendance(attendance);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.attendance == null ? 'تسجيل' : 'تحديث'),
        ),
      ],
    );
  }
}