import 'package:cash_admin/models/daily_payment_summary.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<DailyPaymentSummary>> getAgentPaymentSummaries(String agentId) {
  return FirebaseFirestore.instance
      .collection('payments')
      .where('agentId', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(agentId))
      .orderBy('date', descending: true)
      .snapshots()
      .map((querySnapshot) {
    final Map<String, List<Payment>> dailyPayments = {};

    for (var doc in querySnapshot.docs) {
      final payment = Payment.fromSnapshot(doc);
      // final formattedDate = DateFormat('dd/MM/yyyy').format(payment.date);

      if (!dailyPayments.containsKey(payment.date)) {
        dailyPayments[payment.date] = [];
      }

      dailyPayments[payment.date]!.add(payment);
    }

    final summaries = dailyPayments.entries
        .map((entry) => DailyPaymentSummary(
              date: entry.key,
              totalAmount: entry.value.fold(0, (prev, elem) => prev + elem.amount),
              individualPayments: entry.value,
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return summaries;
  });
}


// Stream<List<DailyPaymentSummary>> getDailyPaymentSummaries(String agentId) {
//   return FirebaseFirestore.instance
//       .collection('payments')
//       .where('agentId', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(agentId))
//       .orderBy('date', descending: true)
//       .snapshots()
//       .map((querySnapshot) {
//     final Map<String, double> dailySums = {};
//     final List<Payment> individualPayments = [];

//     for (var doc in querySnapshot.docs) {
//       final payment = Payment.fromSnapshot(doc);
//       final formattedDate = DateFormat('dd/MM/yyyy').format(payment.date);
//       // if (formattedDate == selectedDate.toString()) { // Filter based on selected date
//       dailySums[formattedDate] = (dailySums[formattedDate] ?? 0.0) + payment.amount;
//       // if(payment.date == formattedDate)
//       individualPayments.add(payment);
//       // }
//     }
//     logger.i("hi: $dailySums");

//     final summaries = dailySums.entries
//         .map((entry) => DailyPaymentSummary(
//               date: entry.key,
//               totalAmount: entry.value,
//               individualPayments: individualPayments,
//             ))
//         .toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//     // logger.i("summ: ${summaries[1].individualPayments![2].date}");

//     return summaries;
//   });
// }


// Stream<List<DailyPaymentSummary>> getDailyPaymentSummaries(String agentId) {
//   return FirebaseFirestore.instance
//       .collection('payments')
//       .where('agentId', isEqualTo: agentId)
//       .orderBy('date', descending: true)
//       .snapshots()
//       .map((querySnapshot) {
//     final Map<DateTime, double> dailySums = {};
//     for (var doc in querySnapshot.docs) {
//       final payment = Payment.fromSnapshot(doc);
//       logger.i("hello: $payment");
//       dailySums[payment.date] = (dailySums[payment.date] ?? 0.0) + payment.amount;
//     }

//     final summaries = dailySums.entries
//         .map((entry) => DailyPaymentSummary(
//               date: entry.key,
//               totalAmount: entry.value,
//             ))
//         .toList()
//       ..sort((a, b) => b.date.compareTo(a.date));

//     return summaries;
//   });
// }

// Stream<List<DailyPaymentSummary>> getDailyPaymentSummaries(String agentId) {
//   return FirebaseFirestore.instance
//       .collection('payments')
//       .where('agentId', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(agentId))
//       .orderBy('date', descending: true)
//       .snapshots()
//       .map((querySnapshot) {
//     // FirebaseFirestore.instance.collection('agents').doc(widget.agent.id)

//     final Map<DateTime, double> dailySums = {};
//     logger.i("just give man : ${querySnapshot.docs.first.data()}");

//     for (var doc in querySnapshot.docs) {
//       logger.i("logger ${doc.data()}");
//       final payment = Payment.fromSnapshot(doc);
//       logger.i("where: $payment");

//       dailySums[payment.date] = (dailySums[payment.date] ?? 0.0) + payment.amount.toDouble();
//       logger.i("just give man 2: $dailySums");
//     }

//     final summaries = dailySums.entries
//         .map((entry) => DailyPaymentSummary(
//               date: entry.key,
//               totalAmount: entry.value,
//             ))
//         .toList()
//       ..sort((a, b) => b.date.compareTo(a.date));
//     logger.i("the i want");
//     logger.i("summary: $summaries");

//     return summaries;
//   });
// }
