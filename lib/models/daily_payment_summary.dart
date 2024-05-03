import 'package:cash_admin/models/payment.dart';

class DailyPaymentSummary {
  final String date;
  final double totalAmount;
  final List<Payment>? individualPayments;

  DailyPaymentSummary({
    required this.date,
    required this.totalAmount,
    required this.individualPayments,
  });
}
