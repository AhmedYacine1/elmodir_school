import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../../../models/staff.dart';

class StaffFormDialog extends ConsumerStatefulWidget {
  final Staff? staff;

  const StaffFormDialog({
    Key? key,
    this.staff,
  }) : super(key: key);

  @override
  ConsumerState<StaffFormDialog> createState() => _StaffFormDialogState();
}

class _StaffFormDialogState extends ConsumerState<StaffFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  String _role = '';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      final staff = widget.staff!;
      _fullNameController.text = staff.fullName;
      _phoneController.text = staff.phone;
      _salaryController.text = staff.salary.toString();
      _role = staff.role;
      _isActive = staff.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.staff == null ? 'إضافة موظف جديد' : 'تعديل بيانات الموظف'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _role.isEmpty ? null : _role,
                  decoration: const InputDecoration(labelText: 'الوظيفة'),
                  items: const [
                    DropdownMenuItem(value: 'teacher', child: Text('معلم')),
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                    DropdownMenuItem(value: 'assistant', child: Text('مساعد')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الوظيفة';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(labelText: 'الراتب'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الراتب';
                    }
                    if (double.tryParse(value) == null) {
                      return 'الرجاء إدخال راتب صحيح';
                    }
                    return null;
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
              final staff = Staff(
                id: widget.staff?.id,
                fullName: _fullNameController.text,
                role: _role,
                phone: _phoneController.text,
                salary: double.parse(_salaryController.text),
                isActive: _isActive,
              );

              if (widget.staff == null) {
                await ref.read(staffProvider.notifier).addStaff(staff);
              } else {
                await ref.read(staffProvider.notifier).updateStaff(staff);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.staff == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}