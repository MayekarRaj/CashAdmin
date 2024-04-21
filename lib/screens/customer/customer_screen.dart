import 'package:cash_admin/models/user.dart';
import 'package:cash_admin/screens/add_payments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerScreen extends StatefulWidget {
  final User user;
  const CustomerScreen({super.key, required this.user});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  // Future<DocumentSnapshot> _createPlaceholderPayment(DateTime currentDate) async {
  //   return await FirebaseFirestore.instance.doc('payments/placeholder').get();
  // }

  // String _formatDuration(Duration duration) {
  //   if (duration.inDays > 0) {
  //     return '${duration.inDays}d';
  //   } else if (duration.inHours > 0) {
  //     return '${duration.inHours}h';
  //   } else if (duration.inMinutes > 0) {
  //     return '${duration.inMinutes}m';
  //   } else {
  //     return 'Just now';
  //   }
  // }

  // int _calculateItemCount(DateTime startDate, DateTime endDate, List<DocumentSnapshot> payments) {
  //   final daysBetween = endDate.difference(startDate).inDays + 1;
  //   return daysBetween + (payments.length > daysBetween ? 0 : daysBetween - payments.length);
  // }

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
          // '+91 ${widget.user.phoneNumber}',
          widget.user.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        // actions: [
        //   PopupMenuButton<String>(
        //     icon: const Icon(
        //       Icons.more_vert,
        //       color: Colors.white,
        //     ), // 3 dots icon
        //     onSelected: (value) {
        //       // Handle menu item selection
        //     },
        //     itemBuilder: (context) => [
        //       PopupMenuItem(
        //         value: 'Details',
        //         child: Text('Details'),
        //         onTap: () {
        //           Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetails(user: widget.user)));
        //         },
        //       ),
        //       // PopupMenuItem(
        //       //   value: 'Option 2',
        //       //   child: Text('Option 2'),
        //       // ),
        //       // PopupMenuItem(
        //       //   value: 'Option 3',
        //       //   child: Text('Option 3'),
        //       // ),
        //     ],
        //   ),
        // ],
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
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: Cros,
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Total',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('payments')
                      .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(widget.user.id))
                      .where('status', isEqualTo: "paid")
                      .snapshots(),
                  // FirebaseFirestore.instance
                  //     .collection('users')
                  //     .doc(widget.user.id)
                  //     .collection('payments')
                  //     .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: Text("₹ 0"));
                    }

                    List<DocumentSnapshot> payments = snapshot.data!.docs;
                    double totalAmount = 0;

                    for (var payment in payments) {
                      totalAmount += payment['amount'];
                    }

                    return Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          '\u{20B9}${totalAmount.toStringAsFixed(0)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("All Payments"),
            ),
            Expanded(
              // child:
              // StreamBuilder<QuerySnapshot>(
              //   stream: FirebaseFirestore.instance
              //       .collection('users')
              //       .doc(widget.user.id)
              //       .collection('payments')
              //       .where('date',
              //           isGreaterThanOrEqualTo: widget.user.timestamp) // Consider starting date from user's timestamp
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text('Error: ${snapshot.error}'));
              //     }

              //     List<DocumentSnapshot> payments = snapshot.data!.docs;

              //     return ListView.builder(
              //       itemCount: DateTime.now().difference(widget.user.timestamp.toDate()).inDays + 1,
              //       itemBuilder: (context, index) {
              //         var currentDate = widget.user.timestamp.toDate().add(Duration(days: index));
              //         var formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);
              //         var matchingPayment = payments.firstWhere((payment) {
              //           var paymentDate = (payment['date'] as Timestamp).toDate();
              //           return paymentDate.year == currentDate.year &&
              //               paymentDate.month == currentDate.month &&
              //               paymentDate.day == currentDate.day;
              //         }, orElse: () => null); // Set to null if no payment found

              //         return FutureBuilder<DocumentSnapshot>(
              //           future: _createPlaceholderPayment(currentDate),
              //           builder: (context, placeholderSnapshot) {
              //             var isPaid = matchingPayment != null;
              //             return ListTile(
              //               minVerticalPadding: 22,
              //               tileColor: isPaid ? Colors.green : Colors.red,
              //               leading: const Icon(
              //                 Icons.payments,
              //                 color: Colors.white,
              //               ),
              //               title: Text(
              //                 isPaid ? '\u{20B9}${matchingPayment!['amount'].toStringAsFixed(0)}' : 'Not Paid',
              //                 style: TextStyle(fontSize: 18, color: Colors.white),
              //               ),
              //               trailing: Text(
              //                 formattedDate,
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //             );
              //           },
              //         );
              //       },
              //     );
              //   },
              // ),
              // StreamBuilder(
              //   stream: FirebaseFirestore.instance
              //       .collection('users')
              //       .doc(widget.user.id)
              //       .collection('payments')
              //       .where('date',
              //           isGreaterThanOrEqualTo: widget.user.timestamp) // Consider starting date from user's timestamp
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text('Error: ${snapshot.error}'));
              //     }

              //     List<DocumentSnapshot> payments = snapshot.data!.docs;

              //     return ListView.builder(
              //       itemCount: DateTime.now().difference(widget.user.timestamp.toDate()).inDays + 1,
              //       itemBuilder: (context, index) {
              //         var currentDate = widget.user.timestamp.toDate().add(Duration(days: index));
              //         var formattedDate = DateFormat('dd/MM/yyyy').format(currentDate);
              //         var matchingPayment = payments.firstWhere((payment) {
              //           var paymentDate = (payment['date'] as Timestamp).toDate();
              //           return paymentDate.year == currentDate.year &&
              //               paymentDate.month == currentDate.month &&
              //               paymentDate.day == currentDate.day;
              //         }, orElse: () => DocumentSnapshot<Object?>{});

              //         var isPaid = matchingPayment.id != 'placeholder';

              //         return ListTile(
              //           minVerticalPadding: 22,
              //           tileColor: matchingPayment != null ? Colors.green : Colors.red,
              //           leading: const Icon(
              //             Icons.payments,
              //             color: Colors.white,
              //           ),
              //           title: Text(
              //             matchingPayment != null
              //                 ? '\u{20B9}${matchingPayment['amount'].toStringAsFixed(0)}'
              //                 : 'Not Paid',
              //             style: TextStyle(fontSize: 18, color: Colors.white),
              //           ),
              //           trailing: Text(
              //             formattedDate,
              //             style: TextStyle(color: Colors.white),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),

              // child: StreamBuilder<QuerySnapshot>(
              //   stream: FirebaseFirestore.instance
              //       .collection('users')
              //       .doc(widget.user.id)
              //       .collection('payments')
              //       .orderBy('date', descending: false) // Sort payments ascending by date
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return const Center(child: CircularProgressIndicator());
              //     }

              //     List<DocumentSnapshot> payments = snapshot.data!.docs;

              //     // Retrieve the starting timestamp from the user's document
              //     final startDate = FirebaseFirestore.instance
              //         .collection('users')
              //         .doc(widget.user.id)
              //         .get()
              //         .then((userDoc) => (userDoc.data()!['timestamp'] as Timestamp).toDate());

              //     return FutureBuilder(
              //       future: startDate, // Get the starting date first
              //       builder: (context, snapshot) {
              //         if (!snapshot.hasData) {
              //           return const Center(child: CircularProgressIndicator());
              //         }

              //         final startDate = snapshot.data as DateTime;
              //         final currentDate = DateTime.now();

              //         return ListView.builder(
              //           itemCount: _calculateItemCount(startDate, currentDate, payments),
              //           itemBuilder: (context, index) {
              //             final itemDate = startDate.add(Duration(days: index));

              //             final paymentDoc =
              //                 payments.firstWhereOrNull((doc) => (doc['date'] as Timestamp).toDate() == itemDate);

              //             final paymentData = paymentDoc?.data() ?? {'amount': 0};
              //             // ?? {'amount': 0}  as Map<String, dynamic>; // Use 0 for placeholder

              //             return ListTile(
              //               onTap: () {},
              //               minVerticalPadding: 22,
              //               tileColor: paymentDoc != null ? Colors.green : Colors.grey[300],
              //               leading: const Icon(
              //                 Icons.payments,
              //                 color: Colors.white,
              //               ),
              //               leadingAndTrailingTextStyle: const TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 16,
              //               ),
              //               title: Text(
              //                 '\u{20B9}${paymentData.toString()}', // Use paymentData for consistency
              //                 // .toStringAsFixed(0)
              //                 style: TextStyle(fontSize: 18, color: Colors.white),
              //               ),
              //               trailing: Text(DateFormat('dd/MM/yyyy').format(itemDate)),
              //             );
              //           },
              //         );
              //       },
              //     );
              //   },
              // ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(widget.user.id))
                    .orderBy('date', descending: true)
                    // .where('status', isEqualTo: "paid")
                    .snapshots(),
                // FirebaseFirestore.instance
                //     .collection('users')
                //     .doc(widget.user.id)
                //     .collection('payments')
                //     .orderBy('date', descending: true)
                //     .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text("No entries"));
                  }

                  List<DocumentSnapshot> payments = snapshot.data!.docs;

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: payments.length,
                    separatorBuilder: (_, index) {
                      return Container(
                        height: 10,
                      );
                    },
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      var paymentDate = (payment['date'] as Timestamp).toDate();
                      var formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

                      return Card(  
                        elevation: 4, // Add elevation for a shadow effect
                        child: ListTile(
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          // enabled: false,
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
                          // trailing: Container(
                          //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.green),
                          //   child: Text(
                          //     payment['status'],
                          //   ),
                          // ),
                          title: Text(
                            '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          trailing: Text(
                            formattedDate,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
            )
          ],
        ),
      ),
    );
  }
}
