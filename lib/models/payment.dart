import 'package:isar/isar.dart';

part 'payment.g.dart';

@collection
class Payment {
  Id? id;
  
  int studentId;
  double amount;
  double discount;
  DateTime paymentDate;
  String status; // paid, partial, unpaid
  String period; // month, term
  
  Payment({
    this.id,
    required this.studentId,
    required this.amount,
    this.discount = 0.0,
    DateTime? paymentDate,
    required this.status,
    required this.period,
  }) : this.paymentDate = paymentDate ?? DateTime.now();
}