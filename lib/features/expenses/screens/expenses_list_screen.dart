import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../../../models/expense.dart';
import '../../../core/database/isar_service.dart';
import '../widgets/expense_form_dialog.dart';

class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  List<Expense> filteredExpenses = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredExpenses = ref.read(expenseProvider);
  }

  void _runFilter(String query) {
    final expenses = ref.read(expenseProvider);
    setState(() {
      if (query.isEmpty) {
        filteredExpenses = expenses;
      } else {
        filteredExpenses = expenses.where((expense) =>
            expense.title.toLowerCase().contains(query.toLowerCase()) ||
            expense.category.toLowerCase().contains(query.toLowerCase()) ||
            expense.amount.toString().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(expenseProvider, (previous, next) {
      _runFilter(searchQuery);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المصاريف'),
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
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          child: ListTile(
                            title: Text(expense.title),
                            subtitle: Text(
                              'الفئة: ${expense.category} | '
                              'المبلغ: ${expense.amount.toStringAsFixed(2)} د.ج | '
                              'التاريخ: ${expense.date.toString().split(' ')[0]}',
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () async {
                                    await _showExpenseFormDialog(context, expense, ref);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _confirmDelete(context, expense.id!, ref),
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
          onPressed: () => _showExpenseFormDialog(context, null, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showExpenseFormDialog(BuildContext context, Expense? expense, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (context) => ExpenseFormDialog(
        expense: expense,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الم支出؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              ref.read(expenseProvider.notifier).deleteExpense(id);
              Navigator.pop(context);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }
}