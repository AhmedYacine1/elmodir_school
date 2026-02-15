import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parent_provider.dart';
import '../../../models/parent.dart';

class ParentFormDialog extends ConsumerStatefulWidget {
  final Parent? parent;

  const ParentFormDialog({
    Key? key,
    this.parent,
  }) : super(key: key);

  @override
  ConsumerState<ParentFormDialog> createState() => _ParentFormDialogState();
}

class _ParentFormDialogState extends ConsumerState<ParentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.parent != null) {
      final parent = widget.parent!;
      _fullNameController.text = parent.fullName;
      _phoneController.text = parent.phone;
      _jobController.text = parent.job ?? '';
      _addressController.text = parent.address ?? '';
      _notesController.text = parent.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.parent == null ? 'إضافة ولي أمر جديد' : 'تعديل بيانات الولي'),
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
                  controller: _jobController,
                  decoration: const InputDecoration(labelText: 'المهنة'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'العنوان'),
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات'),
                  maxLines: 3,
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
              final parent = Parent(
                id: widget.parent?.id,
                fullName: _fullNameController.text,
                phone: _phoneController.text,
                job: _jobController.text.isEmpty ? null : _jobController.text,
                address: _addressController.text.isEmpty ? null : _addressController.text,
                notes: _notesController.text.isEmpty ? null : _notesController.text,
              );

              if (widget.parent == null) {
                await ref.read(parentProvider.notifier).addParent(parent);
              } else {
                await ref.read(parentProvider.notifier).updateParent(parent);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.parent == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}