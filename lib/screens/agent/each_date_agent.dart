import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/daily_payment_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class EachDatePaymentAgent extends StatefulWidget {
  final DailyPaymentSummary dailyPaymentSummary;
  const EachDatePaymentAgent({super.key, required this.dailyPaymentSummary});

  @override
  State<EachDatePaymentAgent> createState() => _EachDatePaymentAgentState();
}

class _EachDatePaymentAgentState extends State<EachDatePaymentAgent> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> fetchUserName(String userId) async {
    String userName = "";
    try {
      DocumentSnapshot userSnapshot = await firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        userName = userSnapshot.get('name');
      }
    } catch (error) {
      logger.e('Error fetching user name: $error');
    }
    return userName;
  }

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
          widget.dailyPaymentSummary.date.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 2),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: widget.dailyPaymentSummary.individualPayments!.length,
                separatorBuilder: (_, index) {
                  return const Gap(10);
                },
                itemBuilder: (context, index) {
                  final payment = widget.dailyPaymentSummary.individualPayments![index];
                  // final DateFormat formatter = DateFormat('dd/MM/yyyy'); // Adjust the format as needed
                  // final String formattedDate = formatter.format(payment.date);

                  // logger.i("payment:len ${widget.dailyPaymentSummary.individualPayments!.length}");
                  // for (var e in widget.dailyPaymentSummary.individualPayments!) {
                  //   // logger.i("payment:for ${e}");
                  //   if (formattedDate == widget.dailyPaymentSummary.date) {
                  //     // return null;
                  //     logger.i("payment: one doc");
                  //   }
                  // }

                  return Material(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2.0,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      minVerticalPadding: 22,
                      tileColor: payment.status == 'paid' ? Colors.green : Colors.red,
                      leading: const Icon(
                        Icons.payments,
                        color: Colors.white,
                      ),
                      leadingAndTrailingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      title: FutureBuilder<String>(
                        future: fetchUserName(payment.userRef),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              '',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(fontSize: 14, color: Colors.white),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? 'User not found',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              );
                            }
                          }
                        },
                      ),
                      trailing: Text(
                        '\u{20B9}${payment.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
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
