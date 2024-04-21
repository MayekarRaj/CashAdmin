import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class AddPayment extends StatefulWidget {
  final User user;
  const AddPayment({super.key, required this.user});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  // String? _selectedPhoneNumber;
  final TextEditingController _paymentController = TextEditingController();
  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _paymentController.text = widget.user.dailyPay.toString();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPaymentsStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('payments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .where('date', isLessThan: Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))))
        .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(currentUserId))
        .snapshots();
  }

  // Future<void> updatePaymentStatusToPaid(String userId, double amount, DateTime date) async {
  //   try {
  //     final paymentsRef = FirebaseFirestore.instance.collection('payments');
  //     final paymentRef = await paymentsRef
  //         .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
  //         .where('date', isLessThan: Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))))
  //         .where('userRef', isEqualTo: userId)
  //         .get();

  //     await paymentRef.update({
  //       'status': 'paid',
  //     });

  //     Fluttertoast.showToast(
  //       msg: 'Payment status updated to paid',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //     Navigator.pop(context); // Assuming you want to navigate back after updating
  //   } catch (error) {
  //     logger.e('Error updating payment status: $error');
  //     Fluttertoast.showToast(
  //       msg: 'Error updating payment status',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }

  Future<void> savePaymentToFirestore(String userId, double amount, DateTime date) async {
    // final userPaymentsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('payments');
    // final userPaymentsRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final mainPaymentsRef = FirebaseFirestore.instance
        .collection('payments')
        .where('status', isEqualTo: "not paid")
        .where("userRef", isEqualTo: FirebaseFirestore.instance.doc("users/$userId"))
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        // .where('date', isGreaterThan: date)
        .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)));
    mainPaymentsRef.get().then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        doc.reference.update({
          "status": "paid",
          "date": Timestamp.fromDate(DateTime.now()),
          "amount": amount,
          "agentId": "admin",
        }).then(
          (value) {
            logger.i("Document updated successfully!");
            Fluttertoast.showToast(
              msg: 'Payment saved successfully',
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
        
        // await updateDocument(doc);
      } else {
        logger.i("No document found to update.");
        Fluttertoast.showToast(msg: "No document found to update.");
      }
      // Loop through each document in the snapshot
      //   for (var document in querySnapshot.docs) {
      //     // Access document data using document.id and document.data()
      //     logger.i('Document ID: ${document.id}');
      //     // logger.i('Document Data: ${document.data()}');
      //   }
      //   logger.i(querySnapshot.docs.length);
    });

    // var list = mainPaymentsRef.get();
    // logger.i(list);

    // final docId = mainPaymentsRef.doc().id;

    // final paymentData = {
    //   'amount': amount,
    //   'date': date,
    //   'status': 'paid',
    //   'agentId': 'admin',
    //   'userRef': userPaymentsRef.doc(docId),
    // };

    // final batch = FirebaseFirestore.instance.batch();
    // batch.set(mainPaymentsRef.doc(docId), paymentData);
    // // batch.set(userPaymentsRef.doc(docId), paymentData);
    // Navigator.pop(context);

    // await batch.commit().then((_) {
    //   Fluttertoast.showToast(
    //     msg: 'Payment saved successfully',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.green,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    //   Navigator.pop(context);
    // }).catchError((error) {
    //   logger.e('Error saving payment: $error');
    //   Fluttertoast.showToast(
    //     msg: 'Error saving payment',
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFC5CEF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
        title: const Text(
          'Add Payment',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Date: $formattedDate',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            const Gap(16),
            Text(widget.user.phoneNumber),
            // Text('Select a number'),
            // StreamBuilder(
            //   stream: FirebaseFirestore.instance.collection('users').snapshots(),
            //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator();
            //     }

            //     if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     }

            //     final List<DocumentSnapshot> documents = snapshot.data!.docs;

            //     List<String> phoneNumbers = [];
            //     for (var doc in documents) {
            //       final userData = doc.data() as Map<String, dynamic>;
            //       final phoneNumber = userData['phoneNumber'];
            //       if (phoneNumber != null) {
            //         phoneNumbers.add(phoneNumber.toString());
            //       }
            //     }

            //     return Container(
            //       padding: EdgeInsets.symmetric(horizontal: 16.0),
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Colors.black, width: 1.0),
            //         borderRadius: BorderRadius.circular(5.0),
            //       ),
            //       child: DropdownButton<String>(
            //         value: _selectedPhoneNumber,
            //         hint: Text('Select a phone number'),
            //         underline: Container(),
            //         onChanged: (value) {
            //           setState(() {
            //             _selectedPhoneNumber = value!;
            //           });
            //         },
            //         items: phoneNumbers.map<DropdownMenuItem<String>>((String phoneNumber) {
            //           return DropdownMenuItem<String>(
            //             value: phoneNumber,
            //             child: Text(phoneNumber),
            //           );
            //         }).toList(),
            //       ),
            //     );
            //   },
            // ),
            const Gap(20),
            const Text('Enter a amount'),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number, // Allow decimal numbers
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                // suffixText: "u\205B",
                prefixText: "\u{20B9}",
                border: OutlineInputBorder(),
                hintText: 'Amount',
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
                  // await showDialo
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of AlertDialog
                      return AlertDialog(
                        title: Text('The amount entered is : $payment'),
                        content: const Text('Are you sure you want to save?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              if (payment.isNotEmpty) {
                                savePaymentToFirestore(widget.user.id, double.parse(payment),
                                    DateTime.now().copyWith(hour: 0, minute: 0, second: 0, microsecond: 0));
                                logger.i(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, microsecond: 0));
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
