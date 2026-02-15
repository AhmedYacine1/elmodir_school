import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';
import '../../../models/class.dart';

class ClassFormDialog extends ConsumerStatefulWidget {
  final ClassModel? classModel;

  const ClassFormDialog({
    Key? key,
    this.classModel,
  }) : super(key: key);

  @override
  ConsumerState<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends ConsumerState<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  String _shift = '';

  @override
  void initState() {
    super.initState();
    if (widget.classModel != null) {
      final classModel = widget.classModel!;
      _nameController.text = classModel.name;
      _capacityController.text = classModel.capacity.toString();
      _shift = classModel.shift;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.classModel == null ? 'إضافة فصل جديد' : 'تعديل بيانات الفصل'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الفصل'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الفصل';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(labelText: 'سعة الفصل'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال سعة الفصل';
                    }
                    if (int.tryParse(value) == null) {
                      return 'الرجاء إدخال عدد صحيح';
                    }
                    if (int.parse(value) <= 0) {
                      return 'يجب أن تكون السعة أكبر من الصفر';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _shift.isEmpty ? null : _shift,
                  decoration: const InputDecoration(labelText: 'الوردية'),
                  items: const [
                    DropdownMenuItem(value: 'morning', child: Text('صباحي')),
                    DropdownMenuItem(value: 'evening', child: Text('مسائي')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _shift = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار الوردية';
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
              final classModel = ClassModel(
                id: widget.classModel?.id,
                name: _nameController.text,
                capacity: int.parse(_capacityController.text),
                shift: _shift,
              );

              if (widget.classModel == null) {
                await ref.read(classProvider.notifier).addClass(classModel);
              } else {
                await ref.read(classProvider.notifier).updateClass(classModel);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.classModel == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}