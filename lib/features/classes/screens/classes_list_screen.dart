import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';
import '../../../models/class.dart';
import '../../../core/database/isar_service.dart';
import '../widgets/class_form_dialog.dart';

class ClassesListScreen extends ConsumerStatefulWidget {
  const ClassesListScreen({super.key});

  @override
  ConsumerState<ClassesListScreen> createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends ConsumerState<ClassesListScreen> {
  List<ClassModel> filteredClasses = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredClasses = ref.read(classProvider);
  }

  void _runFilter(String query) {
    final classes = ref.read(classProvider);
    setState(() {
      if (query.isEmpty) {
        filteredClasses = classes;
      } else {
        filteredClasses = classes.where((classModel) =>
            classModel.name.toLowerCase().contains(query.toLowerCase()) ||
            classModel.shift.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(classProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفصول'),
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
                      itemCount: filteredClasses.length,
                      itemBuilder: (context, index) {
                        final classModel = filteredClasses[index];
                        return Card(
                          child: ListTile(
                            title: Text(classModel.name),
                            subtitle: Text(
                              'السعة: ${classModel.capacity} | '
                              'الوردية: ${classModel.shift} | '
                              'عدد الطلاب: ${_getStudentCount(classModel.id!, ref)}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showClassFormDialog(context, classModel, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, classModel.id!, ref),
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
          onPressed: () => _showClassFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  int _getStudentCount(int classId, WidgetRef ref) {
    // This would need to be implemented properly with a database query
    // For now, returning a placeholder value
    return 0; // Placeholder - would need to query students table
  }

  Future<void> _showClassFormDialog(BuildContext context, ClassModel? classModel, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => ClassFormDialog(
        classModel: classModel,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الفصل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(classProvider.notifier).deleteClass(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}