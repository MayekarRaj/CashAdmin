import 'package:cash_admin/components/base_page.dart';
import 'package:cash_admin/models/agent.dart';
import 'package:cash_admin/models/daily_payment_summary.dart';
import 'package:cash_admin/models/merged_data.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cash_admin/screens/agent/agent_debit_amount.dart';
import 'package:cash_admin/screens/agent/each_date_agent.dart';
import 'package:cash_admin/services/agent_daily_payment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cash_admin/main.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';

class DailyAgentsPaymentsScreen extends StatefulWidget {
  final Agent agent;
  const DailyAgentsPaymentsScreen({super.key, required this.agent});

  @override
  State<DailyAgentsPaymentsScreen> createState() => _DailyAgentsPaymentsScreenState();
}

class _DailyAgentsPaymentsScreenState extends State<DailyAgentsPaymentsScreen> {
  String? _selectedDate;

  Color getTileColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'toAdmin':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  Stream<List<Payment>> getDebitStream(String agentId) {
    final snap = FirebaseFirestore.instance
        .collection('payments')
        .where('agentId', isEqualTo: "admin")
        .where("status", isEqualTo: "toAdmin")
        .where("userRef", isEqualTo: FirebaseFirestore.instance.collection('agents').doc(agentId))
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs.map((doc) => Payment.fromSnapshot(doc)).toList(),
        );

    // snap.listen((payments) {
    //   logger.e('Payments: $payments');
    // });
    return snap;
  }

  Stream<MergedData> mergeStreams(String agentId) {
    final dailyStream = getAgentPaymentSummaries(agentId);
    final debitStream = getDebitStream(agentId);

    return Rx.combineLatest2<List<DailyPaymentSummary>, List<Payment>, MergedData>(
      dailyStream,
      debitStream,
      (dailySummaries, payments) {
        final List<dynamic> mergedList = [...dailySummaries, ...payments];

        // mergedList.sort((a, b) => a.date.compareTo(b.date));
        mergedList.sort((a, b) {
          DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.date);
          DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.date);
          return dateB.compareTo(dateA);
        });

        return MergedData(
          mergedItems: mergedList,
        );
      },
    );
  }

  // Stream<MergedData> mergeStreams(String agentId) {
  //   final dailyStream = getDailyPaymentSummaries(agentId);
  //   final debitStream = getSecondStream(agentId);

  //   return Rx.combineLatest2<List<DailyPaymentSummary>, List<Payment>, MergedData>(
  //     dailyStream,
  //     debitStream,
  //     (dailySummaries, payments) {
  //       // Combine daily summaries and payments
  //       final List<dynamic> mergedList = [...dailySummaries, ...payments];

  //       // Sort the merged list by date
  //       mergedList.sort((a, b) => a.date.compareTo(b.date));

  //       // Separate the merged list into daily summaries and payments again
  //       final List<DailyPaymentSummary> sortedDailySummaries = [];
  //       final List<Payment> sortedPayments = [];
  //       for (final item in mergedList) {
  //         if (item is DailyPaymentSummary) {
  //           sortedDailySummaries.add(item);
  //         } else if (item is Payment) {
  //           sortedPayments.add(item);
  //         }
  //       }

  //       return MergedData(
  //         dailySummaries: sortedDailySummaries,
  //         payments: sortedPayments,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF24274A),
        //   leadingWidth: 45,
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: const Icon(
        //       Icons.arrow_back_ios_new_outlined,
        //     ),
        //     color: Colors.white,
        //   ),
        //   title: Text(
        //     widget.agent.name,
        //     style: const TextStyle(
        //       color: Colors.white,
        //     ),
        //   ),
        //   automaticallyImplyLeading: false,
        // ),
        // floatingActionButton: FloatingActionButton(
        //   shape: const CircleBorder(),
        //   backgroundColor: const Color(0xFF24274A),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => AgentDebitScreen(
        //           agent: widget.agent,
        //         ),
        //       ),
        //     );
        //   },
        //   child: const Center(
        //     child: Icon(
        //       Icons.add,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        // body: Container(
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [
        //         const Color(0xFFD8DCF7).withOpacity(0.25),
        //         const Color(0xFFC5CEF9),
        //       ],
        //     ),
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
        //     child:

        BasePage(
      appBarTitle: widget.agent.name,
      FABBool: true,
      FABPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgentDebitScreen(
              agent: widget.agent,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34.0),
            child: Material(
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 2),
                child: Column(
                  children: [
                    const Align(
                      // alignment: Alignment.centerLeft,
                      child: Text(
                        'Collected Amount:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Align(
                      // alignment: Alignment.centerRight,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('payments')
                            .where('agentId',
                                isEqualTo: FirebaseFirestore.instance.collection('agents').doc(widget.agent.id))
                            .where('status', isEqualTo: "paid")
                            .snapshots(),
                        // FirebaseFirestore.instance
                        //     .collection('users')
                        //     .doc(widget.user.id)
                        //     .collection('payments')
                        //     .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: Text("₹0"));
                          }

                          List<DocumentSnapshot> payments = snapshot.data!.docs;
                          double totalAmount = 0;

                          for (var payment in payments) {
                            logger.i(payment['amount']);
                            totalAmount += payment['amount'];
                          }
                          logger.i(totalAmount);

                          return Text(
                            // '\u{20B9}${totalAmount.toStringAsFixed(0)}',
                            '\u{20B9}${widget.agent.balance}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedDate ?? "All Payments",
                ),
              ),
              //                 IconButton(
              //   onPressed: () async {
              //     final newDateRange = await showDateRangePicker(
              //       context: context,
              //       firstDate: DateTime(2020),
              //       lastDate: DateTime.now(),
              //     );

              //     if (newDateRange != null) {
              //       // Perform filtering based on selected date range
              //       // Update the UI accordingly
              //       final formattedStartDate = DateFormat('dd/MM/yyyy').format(newDateRange.start);
              //       final formattedEndDate = DateFormat('dd/MM/yyyy').format(newDateRange.end);

              //       setState(() {
              //         _selectedDate = '$formattedStartDate - $formattedEndDate';
              //       });
              //     }
              //   },
              //   icon: const Icon(Icons.calendar_today, color: Colors.black),
              // ),

              IconButton(
                onPressed: () async {
                  var newDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (newDate != null) {
                    final formattedDate = DateFormat('dd/MM/yyyy').format(newDate);
                    setState(() {
                      _selectedDate = formattedDate;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today, color: Colors.black),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<MergedData>(
              stream: mergeStreams(widget.agent.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  logger.e(snapshot.error);
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.black),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // final mergedData = snapshot.data!;
                // logger.i("mdata: $mergedData");

                // return ListView(
                //   children: <Widget>[
                //     // Display daily summaries
                //     // ListTile(
                //     //   title: Text('Daily Summaries'),
                //     // ),
                //     for (var summary in mergedData.dailySummaries)
                //       Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 5.0),
                //         child: Material(
                //           clipBehavior: Clip.antiAlias,
                //           elevation: 2.0,
                //           borderRadius: BorderRadius.circular(16),
                //           child: ListTile(
                //             onTap: () {
                //               Navigator.push(
                //                   context,
                //                   MaterialPageRoute(
                //                       builder: (_) => EachDatePaymentAgent(dailyPaymentSummary: summary)));
                //             },
                //             minVerticalPadding: 22,
                //             // tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
                //             // tileColor: getTileColor(payment.),
                //             tileColor: Color(0xFF24274A),
                //             leading: const Icon(
                //               Icons.payments,
                //               color: Colors.white,
                //             ),
                //             leadingAndTrailingTextStyle: const TextStyle(
                //               color: Colors.white,
                //               fontSize: 16,
                //             ),

                //             title: Text(
                //               // formattedDate,
                //               summary.date,
                //               style: const TextStyle(fontSize: 14, color: Colors.white),
                //             ),

                //             trailing: Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Text(
                //                   '\u{20B9}${summary.totalAmount.toStringAsFixed(0)}',
                //                   style: const TextStyle(fontSize: 18, color: Colors.white),
                //                 ),
                //                 const Gap(20),
                //                 const FaIcon(
                //                   FontAwesomeIcons.angleRight,
                //                   size: 16,
                //                   color: Colors.white,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     // ListTile(
                //     //   title: Text(summary.date),
                //     //   subtitle: Text('Total Amount: ${summary.totalAmount}'),
                //     // ),
                //     // Display payments
                //     // ListTile(
                //     //   title: Text('Payments'),
                //     // ),
                //     for (var payment in mergedData.payments)
                //       Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 6.0),
                //         child: Material(
                //           clipBehavior: Clip.antiAlias,
                //           elevation: 2.0,
                //           borderRadius: BorderRadius.circular(16),
                //           child: ListTile(
                //             minVerticalPadding: 22,
                //             tileColor: Colors.red,
                //             // tileColor: getTileColor(payment.status),
                //             // tileColor: Color(0xFF24274A),
                //             leading: const Icon(
                //               Icons.payments,
                //               color: Colors.white,
                //             ),
                //             leadingAndTrailingTextStyle: const TextStyle(
                //               color: Colors.white,
                //               fontSize: 16,
                //             ),

                //             title: Text(
                //               // formattedDate,
                //               payment.date,
                //               style: const TextStyle(fontSize: 14, color: Colors.white),
                //             ),

                //             trailing: Row(
                //               mainAxisSize: MainAxisSize.min,
                //               children: [
                //                 Text(
                //                   '\u{20B9}${payment.amount.toStringAsFixed(0)}',
                //                   style: const TextStyle(fontSize: 18, color: Colors.white),
                //                 ),
                //                 const Gap(20),
                //                 const FaIcon(
                //                   FontAwesomeIcons.angleRight,
                //                   size: 16,
                //                   color: Colors.white,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //     // ListTile(
                //     //   title: Text(payment.date),
                //     //   subtitle: Text('Amount: ${payment.amount}'),
                //     // ),
                //   ],
                // );
                final mergedData = snapshot.data!;
                var mergedItems = mergedData.mergedItems;
                if (_selectedDate != null) {
                  mergedItems = mergedItems.where((item) => item.date == _selectedDate).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: mergedItems.length,
                  separatorBuilder: (_, index) {
                    return const Gap(10);
                  },
                  itemBuilder: (context, index) {
                    final item = mergedItems[index];

                    // var payment = summaries[index];
                    // var paymentDate = payment.date;

                    // for (var summary in mergedData.dailySummaries) {
                    return Material(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        onTap: item.runtimeType == Payment
                            ? null
                            : () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => EachDatePaymentAgent(dailyPaymentSummary: item)));
                              },
                        minVerticalPadding: 22,
                        // tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
                        // tileColor: getTileColor(payment.),
                        tileColor: item.runtimeType == Payment ? Colors.red : Color(0xFF24274A),
                        leading: const Icon(
                          Icons.payments,
                          color: Colors.white,
                        ),
                        leadingAndTrailingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),

                        title: Text(
                          // formattedDate,
                          item.date,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.runtimeType == Payment
                                  ? '\u{20B9}${item.amount.toStringAsFixed(0)}'
                                  : '\u{20B9}${item.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            Gap(
                              item.runtimeType == Payment ? 16 : 20,
                            ),
                            FaIcon(
                              item.runtimeType == Payment ? null : FontAwesomeIcons.angleRight,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                    // }

                    // for (var payment in mergedData.payments) {
                    //   return Material(
                    //     clipBehavior: Clip.antiAlias,
                    //     elevation: 2.0,
                    //     borderRadius: BorderRadius.circular(16),
                    //     child: ListTile(
                    //       // onTap: () {
                    //       //   Navigator.push(context,
                    //       //       MaterialPageRoute(builder: (_) => EachDatePaymentAgent(dailyPaymentSummary: summary)));
                    //       // },
                    //       minVerticalPadding: 22,
                    //       // tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
                    //       // tileColor: getTileColor(payment.),
                    //       tileColor: Color(0xFF24274A),
                    //       leading: const Icon(
                    //         Icons.payments,
                    //         color: Colors.white,
                    //       ),
                    //       leadingAndTrailingTextStyle: const TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 16,
                    //       ),

                    //       title: Text(
                    //         // formattedDate,
                    //         payment.date,
                    //         style: const TextStyle(fontSize: 14, color: Colors.white),
                    //       ),

                    //       trailing: Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Text(
                    //             '\u{20B9}${payment.amount.toStringAsFixed(0)}',
                    //             style: const TextStyle(fontSize: 18, color: Colors.white),
                    //           ),
                    //           const Gap(20),
                    //           const FaIcon(
                    //             FontAwesomeIcons.angleRight,
                    //             size: 16,
                    //             color: Colors.white,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // }
                  },
                );
              },
            ),

            // StreamBuilder<List<DailyPaymentSummary>>(
            //   stream: getDailyPaymentSummaries(widget.agent.id),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasError) {
            //       logger.e(snapshot.error);
            //       return Text(
            //         'Error: ${snapshot.error}',
            //         style: const TextStyle(color: Colors.black),
            //       );
            //     }

            //     if (snapshot.hasData) {
            //       List<DailyPaymentSummary> summaries = snapshot.data!;
            //       if (_selectedDate != null) {
            //         summaries = summaries.where((summary) => summary.date == _selectedDate).toList();
            //       }
            //       return ListView.separated(
            //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            //         itemCount: summaries.length,
            //         separatorBuilder: (_, index) {
            //           return const Gap(10);
            //         },
            //         itemBuilder: (context, index) {
            //           var payment = summaries[index];
            //           var paymentDate = payment.date;

            //           return Material(
            //             clipBehavior: Clip.antiAlias,
            //             elevation: 2.0,
            //             borderRadius: BorderRadius.circular(16),
            //             child: ListTile(
            //               onTap: () {
            //                 Navigator.push(context,
            //                     MaterialPageRoute(builder: (_) => EachDatePaymentAgent(dailyPaymentSummary: payment)));
            //               },
            //               minVerticalPadding: 22,
            //               // tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
            //               // tileColor: getTileColor(payment.),
            //               tileColor: Color(0xFF24274A),
            //               leading: const Icon(
            //                 Icons.payments,
            //                 color: Colors.white,
            //               ),
            //               leadingAndTrailingTextStyle: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 16,
            //               ),

            //               title: Text(
            //                 // formattedDate,
            //                 paymentDate,
            //                 style: const TextStyle(fontSize: 14, color: Colors.white),
            //               ),

            //               trailing: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Text(
            //                     '\u{20B9}${payment.totalAmount.toStringAsFixed(0)}',
            //                     style: const TextStyle(fontSize: 18, color: Colors.white),
            //                   ),
            //                   const Gap(20),
            //                   const FaIcon(
            //                     FontAwesomeIcons.angleRight,
            //                     size: 16,
            //                     color: Colors.white,
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //       // ListView.builder(
            //       //   itemCount: summaries.length,
            //       //   itemBuilder: (context, index) {
            //       //     final summary = summaries[index];
            //       //     return ListTile(
            //       //       title: Text(DateFormat('y MMMM d').format(summary.date)),
            //       //       subtitle: Text('Total: \$' + summary.totalAmount.toStringAsFixed(2)),
            //       //     );
            //       //   },
            //       // );
            //     }

            //     return const Center(child: CircularProgressIndicator());
            //   },
            // ),
            // StreamBuilder<QuerySnapshot>(
            //                 stream:
            //                     // getPaymentStream(widget.agent.id),
            //                     FirebaseFirestore.instance
            //                         .collection('payments')
            //                         // .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(widget.agent.id))
            //                         .where('agentId',
            //                             isEqualTo: FirebaseFirestore.instance.collection('agents').doc(widget.agent.id))
            //                         .orderBy('date', descending: true)
            //                         .snapshots(),
            //                 // FirebaseFirestore.instance
            //                 //     .collection('users')
            //                 //     .doc(widget.user.id)
            //                 //     .collection('payments')
            //                 //     .orderBy('date', descending: true)
            //                 //     .snapshots(),
            //                 builder: (context, snapshot) {
            //                   if (!snapshot.hasData) {
            //                     return const Center(child: Text("No entries"));
            //                   }

            //                   List<DocumentSnapshot> payments = snapshot.data!.docs;

            //                   return ListView.separated(
            //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            //                     itemCount: payments.length,
            //                     separatorBuilder: (_, index) {
            //                       return const Gap(10);
            //                     },
            //                     itemBuilder: (context, index) {
            //                       var payment = payments[index];
            //                       var paymentDate = (payment['date'] as Timestamp).toDate();
            //                       var formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

            //                       return Card(
            //                         elevation: 4,
            //                         child: ListTile(
            //                           // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            //                           // enabled: false,
            //                           onTap: null,
            //                           minVerticalPadding: 22,
            //                           // tileColor: payment['status'] == 'paid' ? Colors.green : Colors.red,
            //                           tileColor: getTileColor(payment["status"]),
            //                           leading: const Icon(
            //                             Icons.payments,
            //                             color: Colors.white,
            //                           ),
            //                           leadingAndTrailingTextStyle: const TextStyle(
            //                             // inherit: false,
            //                             color: Colors.white,
            //                             fontSize: 16,
            //                           ),
            //                           // trailing: Container(
            //                           //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            //                           //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.green),
            //                           //   child: Text(
            //                           //     payment['status'],
            //                           //   ),
            //                           // ),
            //                           title: Text(
            //                             '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
            //                             style: const TextStyle(fontSize: 18, color: Colors.white),
            //                           ),
            //                           trailing: Text(
            //                             formattedDate,
            //                           ),
            //                         ),
            //                       );
            //                     },
            //                   );
            //                 },
            //               ),
          ),
        ],
      ),
    );
    //     ),
    //   ),
    // );
  }
}
