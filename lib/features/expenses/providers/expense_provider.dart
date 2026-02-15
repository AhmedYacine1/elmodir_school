import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/expense.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);

final selectedExpenseProvider = StateProvider<Expense?>((ref) => null);

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = await IsarService.getAllExpenses();
  }

  Future<void> addExpense(Expense expense) async {
    final id = await IsarService.putExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await IsarService.putExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await IsarService.deleteStudent(id); // Note: This might affect related data
    await loadExpenses();
  }
}