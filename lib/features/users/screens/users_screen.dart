import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/user.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../widgets/user_form_dialog.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  List<User> filteredUsers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await IsarService.getAllUsers();
    setState(() {
      filteredUsers = users;
    });
  }

  void _runFilter(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsers = filteredUsers;
      } else {
        filteredUsers = filteredUsers.where((user) =>
            user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.role.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المستخدمون'),
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
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      child: ListTile(
                        title: Text(user.username),
                        subtitle: Text(
                          'الدور: ${user.role}',
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('تعديل'),
                              onTap: () async {
                                await _showUserFormDialog(context, user);
                              },
                            ),
                            PopupMenuItem(
                              child: const Text('حذف'),
                              onTap: () => _confirmDelete(context, user.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showUserFormDialog(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showUserFormDialog(BuildContext context, User? user) async {
    await showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        user: user,
      ),
    );
    _loadUsers(); // Refresh the list after dialog closes
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () async {
              await IsarService.isar.writeTxn(() async {
                await IsarService.isar.users.delete(id);
              });
              Navigator.pop(context);
              _loadUsers(); // Refresh the list
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}