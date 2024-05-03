import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentDateTile extends StatelessWidget {
  // final String date;
  // final double amount;
  // final String status;
  final Payment payment;

  const PaymentDateTile({
    super.key,
    required this.payment,
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
        tileColor: payment.status == 'paid' ? Colors.green : Colors.red,
        leading: const Icon(
          Icons.payments,
          color: Colors.white,
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        title: FutureBuilder<String>(
          future: fetchUserName(payment.userRef),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                '',
                style: TextStyle(fontSize: 14, color: Colors.white),
              );
            } else {
              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                );
              } else {
                return Text(
                  snapshot.data ?? 'User not found',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                );
              }
            }
          },
        ),
        trailing: Text(
          '\u{20B9}${payment.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

Future<String> fetchUserName(String userId) async {
  String userName = "";
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      userName = userSnapshot.get('name');
    }
  } catch (error) {
    logger.e('Error fetching user name: $error');
  }
  return userName;
}
