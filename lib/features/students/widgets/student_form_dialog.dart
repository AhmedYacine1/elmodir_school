import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/student_provider.dart';
import '../../../models/student.dart';
import '../../../models/parent.dart';
import '../../../models/class.dart';
import 'package:uuid/uuid.dart';

class StudentFormDialog extends ConsumerStatefulWidget {
  final Student? student;
  final List<Parent> parents;
  final List<ClassModel> classes;

  const StudentFormDialog({
    Key? key,
    this.student,
    required this.parents,
    required this.classes,
  }) : super(key: key);

  @override
  ConsumerState<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends ConsumerState<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = '';
  int? _parentId;
  int? _classId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      final student = widget.student!;
      _firstNameController.text = student.firstName;
      _lastNameController.text = student.lastName;
      _birthDateController.text = student.birthDate.toString().split(' ')[0];
      _addressController.text = student.address ?? '';
      _gender = student.gender;
      _parentId = student.parentId;
      _classId = student.classId;
      _isActive = student.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'إضافة طالب جديد' : 'تعديل بيانات الطالب'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الأول';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأخير'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الأخير';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.student?.birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _birthDateController.text = date.toString().split(' ')[0];
                      });
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gender.isEmpty ? null : _gender,
                  decoration: const InputDecoration(labelText: 'الجنس'),
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الجنس';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                DropdownButtonFormField<int>(
                  value: _parentId,
                  decoration: const InputDecoration(labelText: 'الوالد'),
                  items: widget.parents.map((parent) {
                    return DropdownMenuItem(
                      value: parent.id,
                      child: Text(parent.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _parentId = value;
                    });
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _classId,
                  decoration: const InputDecoration(labelText: 'الفصل'),
                  items: widget.classes.map((classModel) {
                    return DropdownMenuItem(
                      value: classModel.id,
                      child: Text(classModel.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _classId = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('الحالة النشطة'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
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
              final student = Student(
                id: widget.student?.id,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                birthDate: DateTime.parse(_birthDateController.text),
                gender: _gender,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                parentId: _parentId,
                classId: _classId,
                registrationNumber: widget.student?.registrationNumber ?? Uuid().v4(),
                isActive: _isActive,
                createdAt: widget.student?.createdAt ?? DateTime.now(),
              );

              if (widget.student == null) {
                await ref.read(studentProvider.notifier).addStudent(student);
              } else {
                await ref.read(studentProvider.notifier).updateStudent(student);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.student == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}