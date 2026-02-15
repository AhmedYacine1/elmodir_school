import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/staff_provider.dart';
import '../../../models/staff.dart';
import '../../../core/database/isar_service.dart';
import '../widgets/staff_form_dialog.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  List<Staff> filteredStaff = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredStaff = ref.read(staffProvider);
  }

  void _runFilter(String query) {
    final staff = ref.read(staffProvider);
    setState(() {
      if (query.isEmpty) {
        filteredStaff = staff;
      } else {
        filteredStaff = staff.where((staffMember) =>
            staffMember.fullName.toLowerCase().contains(query.toLowerCase()) ||
            staffMember.role.toLowerCase().contains(query.toLowerCase()) ||
            staffMember.phone.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(staffProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الموظفين'),
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
                      itemCount: filteredStaff.length,
                      itemBuilder: (context, index) {
                        final staffMember = filteredStaff[index];
                        return Card(
                          child: ListTile(
                            title: Text(staffMember.fullName),
                            subtitle: Text(
                              'الوظيفة: ${staffMember.role} | '
                              'الهاتف: ${staffMember.phone} | '
                              'الراتب: ${staffMember.salary.toStringAsFixed(2)} د.ج | '
                              'الحالة: ${staffMember.isActive ? 'نشط' : 'غير نشط'}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showStaffFormDialog(context, staffMember, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, staffMember.id!, ref),
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
          onPressed: () => _showStaffFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showStaffFormDialog(BuildContext context, Staff? staff, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => StaffFormDialog(
        staff: staff,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الموظف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(staffProvider.notifier).deleteStaff(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}