import 'package:cash_admin/models/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Payment>> getCollectedPaymentsStream(DateTime date) {
  return FirebaseFirestore.instance
      .collection('payments')
      .where('status', isEqualTo: 'paid')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
      .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)))
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        return querySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
          return Payment.fromSnapshot(doc);
        }).toList();
      });
}

Stream<List<Payment>> getUnCollectedPaymentsStream(DateTime date) {
  return FirebaseFirestore.instance
      .collection('payments')
      .where('status', isEqualTo: 'not paid')
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
      .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)))
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        return querySnapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
          return Payment.fromSnapshot(doc);
        }).toList();
      });
}

