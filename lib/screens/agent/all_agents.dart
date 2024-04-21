import 'package:cash_admin/constants/appcolors.dart';
import 'package:cash_admin/models/agent.dart';
import 'package:cash_admin/screens/agent/agent_detail_screen.dart';
import 'package:cash_admin/screens/agent/agent_payments_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllAgents extends StatefulWidget {
  const AllAgents({super.key});

  @override
  State<AllAgents> createState() => _AllAgentsState();
}

class _AllAgentsState extends State<AllAgents> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Just now';
    }
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
        title: const Text(
          "All Agents",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        // padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                stream: FirebaseFirestore.instance.collection('agents').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Agent> agents = snapshot.data!.docs.map((doc) {
                    return Agent(
                      id: doc.id,
                      name: doc['name']!,
                      phoneNumber: doc['phoneNumber'],
                      profileImageUrl: doc['profileImageUrl'] ?? "",
                      // panCardImageUrl: doc['panCardImageUrl'],
                      // aadharFrontImageUrl: doc['aadharFrontImageUrl'],
                      // aadharBackImageUrl: doc['aadharBackImageUrl'],
                      timestamp: doc['timestamp'],
                    );
                  }).toList();

                  List<Agent> filteredAgents = agents.where((user) {
                    final nameLower = user.name.toLowerCase();
                    final numberLower = user.phoneNumber.toLowerCase();
                    return nameLower.contains(searchQuery) || numberLower.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredAgents.length,
                    itemBuilder: (context, index) {
                      var agent = filteredAgents[index];
                      final Timestamp timestamp = agent.timestamp;

                      final DateTime creationTime = timestamp.toDate();
                      final Duration difference = DateTime.now().difference(creationTime);
                      final String elapsedTime = _formatDuration(difference);

                      return ListTile(
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
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (_) => AgentDetailScreen(agent: agent)));
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
                                                  title: const Text("Delete Agent"),
                                                  content: const Text("Are you sure you want to delete?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("NO"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore.instance
                                                            .collection('agents')
                                                            .doc(agent.id)
                                                            .delete()
                                                            .whenComplete(
                                                                () => Fluttertoast.showToast(msg: "Agent deleted!"));
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text("YES"),
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DailyAgentsPaymentsScreen(agent: agent)),
                          );
                        },
                        leading: const Icon(Icons.person_outline),
                        title: Text(agent.name),
                        subtitle: Text(agent.phoneNumber),
                        // subtitle: Text('Created $elapsedTime ago'),
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
