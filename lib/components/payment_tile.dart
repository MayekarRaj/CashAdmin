import 'package:flutter/material.dart';

class PaymentTile extends StatelessWidget {
  final String formattedDate;
  final double amount;
  final String status;

  const PaymentTile({
    super.key,
    required this.formattedDate,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: null,
        minVerticalPadding: 22,
        tileColor: status == 'paid' ? Colors.green : Colors.red,
        leading: const Icon(
          Icons.payments,
          color: Colors.white,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
        trailing: Text(
          '\u{20B9}${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
