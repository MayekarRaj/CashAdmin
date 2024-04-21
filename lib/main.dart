import 'package:cash_admin/screens/layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cash_admin/firebase_options.dart';
import 'package:logger/logger.dart';
// import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(persistenceEnabled: true);
  //  await Workmanager().initialize(callbackDispatcher);

  await initializeDateFormatting('en_IN', null);
  // await initializeApp();
  // await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // await Workmanager().registerPeriodicTask(
  //   "dailyUnpaidPayments",
  //   "dailyUnpaidPayments",
  //   // "scheduleDailyUnpaidPayments",
  //   frequency: const Duration(hours: 1), // Daily execution
  // );
  // Workmanager().registerOneOffTask("task-identifier", "simpleTask");

  runApp(const MyApp());
}

// @pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
// void callbackDispatcher() async {
//   Workmanager().executeTask((taskName, inputData) {
//     switch (taskName) {
//       case "dailyUnpaidPayments":
//         scheduleDailyUnpaidPayments();
//         break;
//       default:
//         return Future.value(true);
//     }
//     return Future.value(true);
//   });
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     logger.i("Native called background task: $task"); //simpleTask will be emitted here.
//     return Future.value(true);
//   });
// Future<void> addUnpaidPayment(DocumentReference userRef) async {
//   final userData = await userRef.get();
//   if (userData.exists) {
//     logger.i(userData);
//     final dailyPay = userData.get('daily_pay') as int;
//     final date = DateTime.now();
//     final paymentsRef = FirebaseFirestore.instance.collection('payments');
//     logger.d('doneeeeeeeeeeeeee');
//     await paymentsRef.add({
//       'amount': dailyPay,
//       'date': Timestamp.fromDate(date),
//       'status': 'not paid',
//       'userRef': userRef,
//     });
//   } else {
//     logger.e('User document not found'); // Handle user document not found scenario
//   }
// }

// void scheduleDailyUnpaidPayments() async {
//   logger.d('Daily unpaid payments task started');

//   final users = await getUsers();

//   for (var user in users) {
//     await addUnpaidPayment(user.reference);
//   }

//   logger.d('Daily unpaid payments task completed');
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     // Your background task logic goes here
//     return Future.value(true);
//   });
// }

// void scheduleTask() {
//   Workmanager().registerPeriodicTask();
//   Workmanager().registerOneOffTask(
//     'myTask',
//     'simpleTask',
//     inputData: <String, dynamic>{'key': 'value'},
//   );
// }

// Future<List<DocumentSnapshot>> getUsers() async {
//   final usersRef = FirebaseFirestore.instance.collection('users');
//   final snapshot = await usersRef.get();
//   return snapshot.docs;
// }

// Future<void> initializeApp() async {
//   final prefs = await SharedPreferences.getInstance();
//   final dataAdded = prefs.getBool('dataAdded') ?? false;

//   if (!dataAdded) {
//     await initializePayments();
//     await prefs.setBool('dataAdded', true);
//   }
// }

// Future<void> initializePayments() async {
//   // Get all user IDs (replace with your logic to retrieve user IDs)
//   final userIds = await getUserIds(); // Replace with your user data retrieval

//   final batch = FirebaseFirestore.instance.batch();

//   for (final userId in userIds) {
//     final userPaymentsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('payments');
//     final mainPaymentsRef = FirebaseFirestore.instance.collection('payments');

//     final docId = mainPaymentsRef.doc().id;

//     final paymentData = {
//       'amount': 0.0, // Amount set to 0
//       'date': DateTime.now(), // Use current date
//       'status': 'not paid',
//       'userRef': userPaymentsRef.doc(docId),
//     };

//     batch.set(mainPaymentsRef.doc(docId), paymentData);
//     batch.set(userPaymentsRef.doc(docId), paymentData);
//   }

//   await batch.commit().then((_) {
//     logger.i('Payments initialized successfully');
//   }).catchError((error) {
//     logger.e('Error initializing payments: $error');
//   });
// }

// Replace this with your logic to retrieve user IDs from Firestore or other source
// Future<List<String>> getUserIds() async {
//   // Implement your user ID retrieval logic here
//   // This example assumes you have a collection named 'users' with user ID fields
//   final snapshot = await FirebaseFirestore.instance.collection('users').get();
//   return snapshot.docs.map((doc) => doc.id).toList();
// }

// Future<void> addDataToFirebase() async {

// }

final Logger logger = Logger(
  printer: PrettyPrinter(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cash Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Layout(),
    );
  }
}
