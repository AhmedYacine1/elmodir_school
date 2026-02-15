import 'package:flutter/material.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserFormDialog extends StatefulWidget {
  final User? user;

  const UserFormDialog({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = '';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      final user = widget.user!;
      _usernameController.text = user.username;
      _role = user.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'إضافة مستخدم جديد' : 'تعديل المستخدم'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المستخدم';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'كلمة المرور'),
                  obscureText: true,
                  validator: (value) {
                    if (widget.user == null && (value == null || value.isEmpty)) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (widget.user != null && value != null && value.isNotEmpty && value.length < 6) {
                      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _role.isEmpty ? null : _role,
                  decoration: const InputDecoration(labelText: 'الدور'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('مدير')),
                    DropdownMenuItem(value: 'accountant', child: Text('محاسب')),
                    DropdownMenuItem(value: 'staff', child: Text('موظف')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار دور المستخدم';
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
              String passwordHash = widget.user?.passwordHash ?? '';
              
              if (_passwordController.text.isNotEmpty) {
                var bytes = utf8.encode(_passwordController.text);
                var digest = sha256.convert(bytes);
                passwordHash = digest.toString();
              }

              final user = User(
                id: widget.user?.id,
                username: _usernameController.text,
                passwordHash: passwordHash,
                role: _role,
              );

              await IsarService.putUser(user);

              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: Text(widget.user == null ? 'إضافة' : 'تحديث'),
        ),
      ],
    );
  }
}