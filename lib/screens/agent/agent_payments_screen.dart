import 'package:cash_admin/models/agent.dart';
import 'package:cash_admin/screens/agent/agent_debit_amount.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cash_admin/main.dart';

class DailyAgentsPaymentsScreen extends StatefulWidget {
  final Agent agent;
  const DailyAgentsPaymentsScreen({super.key, required this.agent});

  @override
  State<DailyAgentsPaymentsScreen> createState() => _DailyAgentsPaymentsScreenState();
}

class _DailyAgentsPaymentsScreenState extends State<DailyAgentsPaymentsScreen> {
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
          widget.agent.name,
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => AgentDebitScreen(
          //       agent: widget.agent,
          //     ),
          //   ),
          // );
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
                      .where('agentId', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(widget.agent.id))
                      .where('status', isEqualTo: "paid")
                      .snapshots(),
                  // FirebaseFirestore.instance
                  //     .collection('users')
                  //     .doc(widget.user.id)
                  //     .collection('payments')
                  //     .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text("₹ 0"));
                    }

                    List<DocumentSnapshot> payments = snapshot.data!.docs;
                    double totalAmount = 0;

                    for (var payment in payments) {
                      logger.i(payment['amount']);
                      totalAmount += payment['amount'];
                    }
                    logger.i(totalAmount);

                    return Align(
                      alignment: Alignment.center,
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
            const Gap(18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("All Payments"),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('agentId', isEqualTo: FirebaseFirestore.instance.collection('agents').doc(widget.agent.id))
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: payments.length,
                    separatorBuilder: (_, index) {
                      return const Gap(10);
                    },
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      var paymentDate = (payment['date'] as Timestamp).toDate();
                      var formattedDate = DateFormat('dd/MM/yyyy').format(paymentDate);

                      return Card(
                        elevation: 4,
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
                            style: const TextStyle(fontSize: 18, color: Colors.white),
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
