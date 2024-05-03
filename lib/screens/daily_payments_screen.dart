import 'package:cash_admin/components/payment_date_tile.dart';
import 'package:cash_admin/main.dart';
import 'package:cash_admin/models/payment.dart';
import 'package:cash_admin/services/daily_payments_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DailyPaymentsScreen extends StatefulWidget {
  final DateTime selectedDate;
  const DailyPaymentsScreen({super.key, required this.selectedDate});

  @override
  State<DailyPaymentsScreen> createState() => _DailyPaymentsScreenState();
}

class _DailyPaymentsScreenState extends State<DailyPaymentsScreen> with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  final List<String> categories = ['Collected', 'Uncollected'];
  late TabController _tabController;

  String formatDateToIndianStandard(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy'); // Indian standard format (dd/MM/yyyy)
    return formatter.format(date);
  }

  @override
  void initState() {
    super.initState();
    getUserList();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future getUserList() async {
    var userList = await FirebaseFirestore.instance.collection("users").get();
    // for (var doc in userList.docs) {
    //   logger.i(doc.data()); // Print the document data (including all fields)
    // }
    // logger.i(userList.docs);
    return userList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
        title: Text(
          'Payments: ${formatDateToIndianStandard(widget.selectedDate)}',
          style: const TextStyle(
            fontSize: 20,
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
        bottom: TabBar(
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.fill,
          // indicatorWeight: 3.0,
          indicatorPadding: const EdgeInsets.all(8),
          indicator: BoxDecoration(
            color: Colors.white, // Set the indicator color
            borderRadius: BorderRadius.circular(20), // Optional: Set border radius
          ),
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Colors.white,
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          // indicatorColor: gold,
          labelPadding: const EdgeInsets.symmetric(horizontal: 14.0),
          // controller: _tabController,
          tabs: categories.map((category) => Tab(text: category)).toList(),
        ),
      ),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      // ),
      body: Column(
        children: [
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.06,
          // ),
          // DateTime(year)
          // DatePicker(
          //   // width: 48,
          //   width: MediaQuery.of(context).size.width * 0.127,
          //   DateTime.now().subtract(const Duration(days: 6)),
          //   // DateTime(2024, 3, 01),

          //   daysCount: 7,
          //   initialSelectedDate: DateTime.now(),
          //   selectionColor: Colors.black,
          //   selectedTextColor: Colors.white,
          //   onDateChange: (date) {
          //     // New date selected
          //     setState(() {
          //       // _selectedValue = date;
          //     });
          //   },
          // ),
          // HorizontalCalendar(
          //   date: selectedDate,
          //   textColor: Colors.black45,
          //   backgroundColor: Colors.white,
          //   selectedColor: Colors.blue,
          //   // locale: Locale(
          //   //   'en',
          //   // ),
          //   showMonth: true,
          //   onDateSelected: (date) {
          //     logger.i(date.toString());
          //   },
          // // ),
          // HorizontalWeekCalendar(
          //   weekStartFrom: WeekStartFrom.Sunday,
          //   onDateChange: (date) {
          //     setState(() {
          //       selectedDate = date;
          //     });
          //     logger.i(selectedDate);
          //   },
          // ),
          // SizedBox(
          //   height: 20,
          // ),
          Expanded(
            child: Column(
              children: [
                // TabBar(
                //   padding: EdgeInsets.zero,
                //   tabAlignment: TabAlignment.fill,
                //   indicatorWeight: 3.0,
                //   indicatorPadding: const EdgeInsets.all(6),
                //   controller: _tabController,
                //   indicatorSize: TabBarIndicatorSize.tab,
                //   // indicatorColor: gold,
                //   labelPadding: const EdgeInsets.symmetric(horizontal: 14.0),
                //   // controller: _tabController,
                //   tabs: categories.map((category) => Tab(text: category)).toList(),
                // ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // CollectedItemsListView(date: selectedDate),
                      _collectedPaymentsListView(widget.selectedDate),
                      // UncollectedItemsListView(date: selectedDate),
                      _uncollectedPaymentsListView(widget.selectedDate),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _collectedPaymentsListView(DateTime date) {
  return StreamBuilder<List<Payment>>(
    stream: getCollectedPaymentsStream(date),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.data!.isEmpty) {
        return const Center(
          child: Text('No Entries'),
        );
      }

      double totalAmount = snapshot.data!.fold(0, (previousValue, payment) => previousValue + payment.amount);

      return Column(
        children: [
          const Gap(12),
          const Text(
            "Today's collected amount:",
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '\u{20B9}${totalAmount.toStringAsFixed(0)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              separatorBuilder: (_, index) {
                return const Gap(10);
              },
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final payment = snapshot.data![index];
                return PaymentDateTile(payment: payment);
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _uncollectedPaymentsListView(DateTime date) {
  return StreamBuilder<List<Payment>>(
    stream: getUnCollectedPaymentsStream(date),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.data!.isEmpty) {
        return const Center(
          child: Text('No Entries'),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        separatorBuilder: (_, index) {
          return const Gap(10);
        },
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final payment = snapshot.data![index];
          return PaymentDateTile(payment: payment);
        },
      );
    },
  );
}

class CollectedItemsListView extends StatelessWidget {
  final DateTime date;
  const CollectedItemsListView({Key? key, required this.date}) : super(key: key);

  // Stream<QuerySnapshot> get filteredPaymentsStream {
  //   // Convert selected date to Timestamp for Firestore comparison
  //   final Timestamp selectedDateTimestamp = Timestamp.fromDate(date);

  //   return FirebaseFirestore.instance
  //       .collection('payments')
  //       .where('status', isEqualTo: 'paid')
  //       // .where('date', isLessThanOrEqualTo: date)
  //       .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
  //       .where('date', isLessThan: selectedDateTimestamp.toDate().add(Duration(days: 1))) // Corrected line

  //       .snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'paid')
          // .where('date', isLessThanOrEqualTo: date)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
          .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)))
          .snapshots(),
      builder: (context, snapshot) {
        logger.i(Timestamp.fromDate(date));
        logger.i(date);
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.size == 0) {
          return const Center(
            child: Text('No Enteries'),
          );
        }

        final payments = snapshot.data!.docs.map((doc) => doc.data()).toList();
        // logger.i(payment)

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final timestamp = payment['date'] as Timestamp;
            final date = timestamp.toDate();
            final ref = payment['userRef'].toString().split('/')[1];
            // final amount = payment['amount'];
            // // final date = payment['date'];
            // final timestamp = payment['date'] as Timestamp;
            // logger.i(timestamp);
            // final date = timestamp.toDate();
            // logger.i(date);
            // final status = payment['status'];
            return GestureDetector(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentDetailsScreen()));
              },
              child: Container(
                height: 60,
                color: Colors.green,
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('users').doc(ref.toString()).snapshots(),
                        builder: (context, snapshot) {
                          // logger.i(snapshot.data!.data()!['name']);

                          if (!snapshot.hasData) {
                            return Container();
                          }

                          return Text(
                            snapshot.data?.data()!['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      Spacer(),
                      Text(
                        '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
            ListTile(
              onTap: () {},
              minVerticalPadding: 22,
              tileColor: Colors.green,
              leading: const Icon(
                Icons.payments,
                color: Colors.white,
              ),
              leadingAndTrailingTextStyle: const TextStyle(
                // inherit: false,
                color: Colors.white,
                fontSize: 16,
              ),
              textColor: Colors.white,
              // trailing: Container(
              //   padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.green),
              //   child: Text(
              //     payment['status'],
              //   ),
              // ),
              trailing: Text(
                '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              title: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(ref.toString()).snapshots(),
                builder: (context, snapshot) {
                  // logger.i(snapshot.data!.data()!['name']);

                  if (!snapshot.hasData) {
                    return Container();
                  }

                  return Text(snapshot.data?.data()!['name']);
                },
              ),
              // trailing: Text(
              //   DateFormat('dd/MM/yyyy').format(date),
              // ),
            );
          },
        );
      },
    );

    // return ListView.builder(
    //   itemCount: uncollectedItems.length,
    //   itemBuilder: (context, index) {
    //     final item = uncollectedItems[index];
    //     return ListTile(
    //       title: Text(item),
    //     );
    //   },
    // );
  }
}

class UncollectedItemsListView extends StatelessWidget {
  final DateTime date;

  const UncollectedItemsListView({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual list of uncollected items
    // final List<String> uncollectedItems = ['Item 4', 'Item 5', 'Item 6'];

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('payments')
          .where('status', isEqualTo: 'not paid')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(date))
          .where('date', isLessThan: Timestamp.fromDate(date).toDate().add(const Duration(days: 1)))
          .snapshots(),
      builder: (context, snapshot) {
        logger.i(Timestamp.fromDate(date));
        logger.i(date);
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.size == 0) {
          return Center(
            child: Text('No Enteries'),
          );
        }

        final payments = snapshot.data!.docs.map((doc) => doc.data()).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            final amount = payment['amount'];
            // final date = payment['date'];
            final timestamp = payment['date'] as Timestamp;
            final date = timestamp.toDate();
            final status = payment['status'];
            final ref = payment['userRef'].toString().split('/')[1];
            // logger.i('Hello: ${ref.toString().split('/')[1]}');
            return Container(
              height: 60,
              color: Colors.red,
              margin: EdgeInsets.symmetric(vertical: 6),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.payments,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users').doc(ref.toString()).snapshots(),
                      builder: (context, snapshot) {
                        // logger.i(snapshot.data!.data()!['name']);

                        if (!snapshot.hasData) {
                          return Container();
                        }

                        return Text(
                          snapshot.data?.data()!['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Text(
                      '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
            ListTile(
              onTap: () {},
              minVerticalPadding: 22,
              tileColor: Colors.red,
              leading: const Icon(
                Icons.payments,
                color: Colors.white,
              ),
              leadingAndTrailingTextStyle: const TextStyle(
                // inherit: false,
                color: Colors.white,
                fontSize: 16,
              ),

              title:
                  // StreamBuilder(
                  //     stream: FirebaseFirestore.instance.collection('users').doc(ref).snapshots(),
                  //     builder: (context, index) {
                  //       // final data = snapshot.data as Map<String, dynamic>;
                  //       if (snapshot.hasError) {
                  //         return Text('Error: ${snapshot.error}');
                  //       }

                  //       if (!snapshot.hasData) {
                  //         return const Center(child: CircularProgressIndicator());
                  //       }
                  //       final data = snapshot.data!.data();
                  //       if (data != null) {
                  //         final name = data['name'];
                  //         return Text(name);
                  //       } else {
                  //         return const Text('No user data found');
                  //       }

                  //       // return Text(data['name']);
                  //     }),
                  Text(
                '\u{20B9}${payment['amount'].toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              trailing: Text(
                DateFormat('dd/MM/yyyy').format(date),
              ),
              // Text(
              //   DateFormat('dd/MM/yyyy').format(date),
              // ),
            );
          },
        );
      },
    );
  }
}
