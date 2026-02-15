import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_service.dart';
import '../../../models/payment.dart';

final paymentProvider = StateNotifierProvider<PaymentNotifier, List<Payment>>(
  (ref) => PaymentNotifier(),
);

final selectedPaymentProvider = StateProvider<Payment?>((ref) => null);

class PaymentNotifier extends StateNotifier<List<Payment>> {
  PaymentNotifier() : super([]) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    state = await IsarService.getAllPayments();
  }

  Future<void> addPayment(Payment payment) async {
    final id = await IsarService.putPayment(payment);
    await loadPayments();
  }

  Future<void> updatePayment(Payment payment) async {
    await IsarService.putPayment(payment);
    await loadPayments();
  }

  Future<void> deletePayment(int id) async {
    await IsarService.isar.writeTxn(() async {
      await IsarService.isar.payments.delete(id);
    });
    await loadPayments();
  }
}