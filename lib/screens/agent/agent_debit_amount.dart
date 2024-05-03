import 'package:cash_admin/components/base_page.dart';
import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/agent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class AgentDebitScreen extends StatefulWidget {
  final Agent agent;
  const AgentDebitScreen({super.key, required this.agent});

  @override
  State<AgentDebitScreen> createState() => _AgentDebitScreenState();
}

class _AgentDebitScreenState extends State<AgentDebitScreen> {
  final TextEditingController _paymentController = TextEditingController();
  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // _paymentController.text = widget.user.dailyPay.toString();
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getPaymentsStream(String currentUserId) {
  //   return FirebaseFirestore.instance
  //       .collection('payments')
  //       .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
  //       .where('date', isLessThan: Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))))
  //       .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(currentUserId))
  //       .snapshots();
  // }

  Future fetchAgentbalance(String field) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot agentSnapshot = await firestore.collection('agents').doc(widget.agent.id).get();

      if (agentSnapshot.exists) {
        dynamic agentBalance = agentSnapshot.get(field);

        return agentBalance;
      } else {
        return 0;
      }
    } catch (e) {
      logger.i('Error fetching agent field: $e');
      return 0;
    }
  }

  // Stream<List<int>> mergeStreams() {
  //   return StreamZip([streamController1.stream, streamController2.stream]).map((list) {
  //     final mergedList = <int>[];
  //     for (final item in list) {
  //       mergedList.addAll(item);
  //     }
  //     return mergedList;
  //   });
  // }



  Future<void> paymentAgentToAdmin(String userId, double amount, DateTime date) async {
    // final userPaymentsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('payments');
    final agentPaymentsRef = FirebaseFirestore.instance.collection('agents').doc(widget.agent.id);
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final agentBalance = await fetchAgentbalance("balance");

    // FirebaseFirestore.instance
    //     .collection('payments')
    //     .where('agentId', isEqualTo: "admin")
    //     .where("status", isEqualTo: "toAdmin")
    //     .where("userRef", isEqualTo: agentPaymentsRef)
    //     .orderBy('date', descending: true)
    //     .snapshots();

    await firestore.collection('payments').add({
      'date': Timestamp.now(),
      'status': 'toAdmin',
      'amount': amount,
      'agentId': 'admin',
      'userRef': agentPaymentsRef,
    }).then(
      (value) {
        firestore.collection('agents').doc(widget.agent.id).update({
          "balance": agentBalance - amount,
        });
        logger.i("Document updated successfully!");
        Fluttertoast.showToast(
          msg: 'Amount debited successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      },
    ).catchError((error) {
      logger.e("Error updating document: $error");
      Fluttertoast.showToast(
        msg: 'Error saving payment',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
    // final mainPaymentsRef = FirebaseFirestore.instance.collection('payments');
    // // .where('status', isEqualTo: "not paid")
    // // .where("userRef", isEqualTo: FirebaseFirestore.instance.doc("users/$userId"))
    // // .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
    // // .where('date', isGreaterThan: date)
    // // .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)));
    // mainPaymentsRef.get().then((querySnapshot) {
    //   if (querySnapshot.docs.isNotEmpty) {
    //     DocumentSnapshot doc = querySnapshot.docs.first;
    //     doc.reference.update({
    //       "status": "paid",
    //       "date": Timestamp.fromDate(DateTime.now()),
    //       "amount": amount,
    //       "agentId": "admin",
    //     });

    //     // await updateDocument(doc);
    //   } else {
    //     logger.i("No document found to update.");
    //     Fluttertoast.showToast(msg: "No document found to update.");
    //   }
    // Loop through each document in the snapshot
    //   for (var document in querySnapshot.docs) {
    //     // Access document data using document.id and document.data()
    //     logger.i('Document ID: ${document.id}');
    //     // logger.i('Document Data: ${document.data()}');
    //   }
    //   logger.i(querySnapshot.docs.length);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBarTitle: "Add Payment",
      FABBool: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.calendarDays),
                const Gap(12),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.solidUser),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.agent.name,
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.agent.phoneNumber,
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(28),
            // const Text('Enter a amount'),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 20),
              // decoration: InputDecoration(
              //   hintText: 'Username',
              //   prefixIcon: Icon(Icons.person),
              //   border: OutlineInputBorder(),
              // ),
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                prefixText: "\u{20B9}",
                border: OutlineInputBorder(),
                // hintText: 'Amount',
              ),
            ),
            const Gap(20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24274A),
                ),
                onPressed: () async {
                  final String payment = _paymentController.text;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              const TextSpan(
                                text: 'The amount entered is: ',
                                style: TextStyle(fontSize: 20),
                              ),
                              TextSpan(
                                text: '₹$payment',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Text(
                        //                 'The amount entered is: ₹$payment',
                        //                 style: TextStyle(
                        //                   fontSize: 20,
                        //                 ),
                        //               ),
                        content: const Text('Are you sure you want to save?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (payment.isNotEmpty) {
                                paymentAgentToAdmin(widget.agent.id, double.parse(payment),
                                    DateTime.now().copyWith(hour: 0, minute: 0, second: 0, microsecond: 0));
                                logger.i(DateTime.now()
                                    .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Please select a phone number and enter a payment amount',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                              Navigator.pop(context);
                            },
                            child: const Text('YES'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('NO'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
