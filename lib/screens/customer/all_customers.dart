import 'package:cash_admin/models/user.dart';
import 'package:cash_admin/constants/appcolors.dart';
import 'package:cash_admin/screens/customer/customer_details.dart';
import 'package:cash_admin/screens/customer/customer_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class AllCustomerScreen extends StatefulWidget {
  const AllCustomerScreen({super.key});

  @override
  State<AllCustomerScreen> createState() => _AllCustomerScreenState();
}

class _AllCustomerScreenState extends State<AllCustomerScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF24274A),
        // automaticallyImplyLeading: false,
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
        title: const Text(
          "All Customers",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFD8DCF7).withOpacity(0.25),
              const Color(0xFFC5CEF9),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    labelStyle: TextStyle(color: primary),
                    hintText: 'Enter name or number',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: primary),
                    ),
                    prefixIcon: Icon(Icons.search, color: primary),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: primary),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    ),
                  ),
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<User> users = snapshot.data!.docs.map((doc) {
                    return User(
                      id: doc.id,
                      name: doc['name'],
                      phoneNumber: doc['phoneNumber'],
                      dailyPay: doc['daily_pay'],
                      profileImageUrl: doc['profileImageUrl'],
                      panCardImageUrl: doc['panCardImageUrl'],
                      aadharFrontImageUrl: doc['aadharFrontImageUrl'],
                      aadharBackImageUrl: doc['aadharBackImageUrl'],
                      timestamp: doc['timestamp'],
                    );
                  }).toList();

                  List<User> filteredUsers = users.where((user) {
                    final nameLower = user.name.toLowerCase();
                    final numberLower = user.phoneNumber.toLowerCase();
                    return nameLower.contains(searchQuery) || numberLower.contains(searchQuery);
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (context, index) {
                      return const Gap(8);
                    },
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index];
                      final Timestamp timestamp = user.timestamp;

                      final DateTime creationTime = timestamp.toDate();
                      final Duration difference = DateTime.now().difference(creationTime);
                      final String elapsedTime = _formatDuration(difference);

                      return Material(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: const EdgeInsets.all(16.0),
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.circleInfo,
                                          color: primary,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);

                                          Navigator.push(
                                              context, MaterialPageRoute(builder: (_) => CustomerDetails(user: user)));
                                        },
                                      ),
                                      // Gap(20),
                                      IconButton(
                                        icon: FaIcon(
                                          FontAwesomeIcons.trash,
                                          color: primary,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: const Text("Delete User"),
                                                content: const Text("Are you sure you want to delete the user?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("NO"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection('users')
                                                          .doc(user.id)
                                                          .delete()
                                                          .whenComplete(
                                                              () => Fluttertoast.showToast(msg: "User deleted!"));
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("YES"),
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CustomerScreen(
                                          user: user,
                                        )));
                          },
                          isThreeLine: false,
                          leading: const FaIcon(FontAwesomeIcons.solidUser),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(user.phoneNumber),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(elapsedTime),
                              const Gap(6),
                              const FaIcon(FontAwesomeIcons.angleRight),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
