import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Payment {
  final String id;
  final String date;
  final double amount;
  final String status;
  // final DocumentReference userRef;
  // final DocumentReference agentId;
  final String userRef;
  final String agentId;

  Payment({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.userRef,
    required this.agentId,
  });

  factory Payment.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    // logger.f("inside: $snapshot");
    // logger.i("payment data: ${(snapshot.data()!["userRef"] as DocumentReference).toString()}");
    // logger.i("payment data 1: ${snapshot.data()!['agentId'].runtimeType}");
    // logger.i("payment data 3: ${(snapshot.data()!["userRef"] as DocumentReference).path.split("/")[1]}");

    return Payment(
      id: snapshot.id,
      date: DateFormat('dd/MM/yyyy').format((snapshot.data()!['date'] as Timestamp).toDate()),
      amount: (snapshot.data()!['amount'] as num).toDouble(),
      status: snapshot.data()!['status'],
      userRef: snapshot.data()!["userRef"].runtimeType == String
          ? snapshot.data()!["userRef"].toString()
          : (snapshot.data()!["userRef"] as DocumentReference).path.split("/")[1],
      agentId: snapshot.data()!["agentId"].runtimeType == String
          ? snapshot.data()!["agentId"].toString()
          : (snapshot.data()!["agentId"] as DocumentReference).path.split("/")[1],
    );
  }

  String documentReferenceToString(DocumentReference documentReference) {
    return documentReference.path;
  }
}
