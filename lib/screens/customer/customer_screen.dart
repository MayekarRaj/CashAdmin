import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cash_admin/models/user.dart';
import 'package:cash_admin/screens/add_payments.dart';
import 'package:cash_admin/services/get_payments_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CustomerScreen extends StatefulWidget {
  final User user;
  const CustomerScreen({super.key, required this.user});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
        leadingWidth: 45,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
          color: Colors.white,
        ),
        title: Text(
          widget.user.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF24274A),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddPayment(
                      user: widget.user,
                    )),
          );
        },
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34.0),
              child: Material(
                elevation: 8.0,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 2),
                  child: Column(
                    children: [
                      const Align(
                        // alignment: Alignment.center,
                        child: Text(
                          'Collected Amount:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('payments')
                            .where('userRef',
                                isEqualTo: FirebaseFirestore.instance.collection('users').doc(widget.user.id))
                            .where('status', isEqualTo: "paid")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: Text("₹ 0"));
                          }

                          List<DocumentSnapshot> payments = snapshot.data!.docs;
                          double totalAmount = 0;

                          for (var payment in payments) {
                            totalAmount += payment['amount'];
                          }

                          return Align(
                            // alignment: Alignment.center,
                            child: Text(
                              '\u{20B9}${totalAmount.toStringAsFixed(0)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectedDate ?? "All Payments",
                    // "All Payments",
                  ),
                ),
                // IconButton(
                //   onPressed: () async {
                //     var newDate = await showDatePicker(
                //       context: context,
                //       initialDate: DateTime.now(),
                //       firstDate: DateTime(2020),
                //       lastDate: DateTime.now(),
                //     );

                //     if (newDate != null) {
                //       final formattedDate = DateFormat('dd/MM/yyyy').format(newDate);
                //       setState(() {
                //         _selectedDate = formattedDate;
                //       });
                //     }
                //   },
                //   icon: const Icon(Icons.calendar_today, color: Colors.black),
                // ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(widget.user.id))
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    logger.e(snapshot.error);
                    logger.e(widget.user.id);

                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No entries"));
                  }

                  List<DocumentSnapshot> payments = snapshot.data!.docs;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: payments.length,
                    separatorBuilder: (_, index) {
                      return const Gap(12);
                    },
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      var paymentDate = (payment['date'] as Timestamp).toDate();
                      var formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

                      return Material(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          onTap: null,
                          minVerticalPadding: 22,
                          tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
                          leading: const Icon(
                            Icons.payments,
                            color: Colors.white,
                          ),
                          leadingAndTrailingTextStyle: const TextStyle(
                            // inherit: false,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          title: Text(
                            formattedDate,  
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          trailing: Text(
                            '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // StreamBuilder<List<Payment>>(
              //   stream: getPaymentsForUser(widget.user.id),
              //   // FirebaseFirestore.instance
              //   //     .collection('payments')
              //   //     .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(widget.user.id))
              //   //     .orderBy('date', descending: true)
              //   //     // .where('status', isEqualTo: "paid")
              //   //     .snapshots(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     if (snapshot.hasError) {
              //       logger.e(snapshot.error);
              //       logger.e(widget.user.id);

              //       return Center(child: Text('Error: ${snapshot.error}'));
              //     }
              //     if (!snapshot.hasData) {
              //       return const Center(child: Text("No entries"));
              //     }

              //     List<Payment> payments = snapshot.data!;
              //     // logger.i("for user: ${payments.length}");/

              //     if (_selectedDate != null) {
              //       payments = payments.where((payment) => payment.date == _selectedDate).toList();
              //     }

              //     return ListView.separated(
              //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              //       itemCount: payments.length,
              //       separatorBuilder: (_, index) {
              //         return const Gap(12);
              //       },
              //       itemBuilder: (context, index) {
              //         var payment = payments[index];

              //         return Material(
              //           clipBehavior: Clip.antiAlias,
              //           elevation: 2.0,
              //           borderRadius: BorderRadius.circular(16),
              //           child: ListTile(
              //             onTap: null,
              //             minVerticalPadding: 22,
              //             tileColor: payment.status == 'paid' ? Colors.green : Colors.red,
              //             leading: const Icon(
              //               Icons.payments,
              //               color: Colors.white,
              //             ),
              //             leadingAndTrailingTextStyle: const TextStyle(
              //               color: Colors.white,
              //               fontSize: 16,
              //             ),
              //             title: Text(
              //               payment.date,
              //               style: const TextStyle(fontSize: 15, color: Colors.white),
              //             ),
              //             trailing: Text(
              //               '\u{20B9}${payment.amount.toStringAsFixed(0)}',
              //               style: const TextStyle(fontSize: 18, color: Colors.white),
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
            )
          ],
        ),
      ),
    );
  }
}
