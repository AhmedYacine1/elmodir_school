import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id? id;
  
  String title;
  String category;
  double amount;
  DateTime date;
  String? notes;
  
  Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    DateTime? date,
    this.notes,
  }) : this.date = date ?? DateTime.now();
}