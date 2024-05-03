import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Payment>> getPaymentsForUser(String userId) {
  try {
    logger.i("user: $userId");
    return FirebaseFirestore.instance
        .collection('payments')
        .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId))
        .orderBy('date', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => Payment.fromSnapshot(doc)).toList();
    });
  } catch (e) {
    // Handle the exception here (e.g., print error message, log error)
    logger.e("Error getting payments: $e"); // Example logging

    // Re-throw the exception if necessary
    rethrow;
  }
}
