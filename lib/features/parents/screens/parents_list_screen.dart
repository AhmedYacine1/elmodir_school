import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parent_provider.dart';
import '../../../models/parent.dart';
import '../../../core/database/isar_service.dart';
import '../widgets/parent_form_dialog.dart';

class ParentsListScreen extends ConsumerStatefulWidget {
  const ParentsListScreen({super.key});

  @override
  ConsumerState<ParentsListScreen> createState() => _ParentsListScreenState();
}

class _ParentsListScreenState extends ConsumerState<ParentsListScreen> {
  List<Parent> filteredParents = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredParents = ref.read(parentProvider);
  }

  void _runFilter(String query) {
    final parents = ref.read(parentProvider);
    setState(() {
      if (query.isEmpty) {
        filteredParents = parents;
      } else {
        filteredParents = parents.where((parent) =>
            parent.fullName.toLowerCase().contains(query.toLowerCase()) ||
            parent.phone.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(parentProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الآباء'),
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
                      itemCount: filteredParents.length,
                      itemBuilder: (context, index) {
                        final parent = filteredParents[index];
                        return Card(
                          child: ListTile(
                            title: Text(parent.fullName),
                            subtitle: Text(
                              'الهاتف: ${parent.phone} | '
                              'المهنة: ${parent.job ?? 'غير محدد'}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showParentFormDialog(context, parent, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, parent.id!, ref),
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
          onPressed: () => _showParentFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showParentFormDialog(BuildContext context, Parent? parent, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => ParentFormDialog(
        parent: parent,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الوالد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(parentProvider.notifier).deleteParent(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}