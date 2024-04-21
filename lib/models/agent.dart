import 'package:cloud_firestore/cloud_firestore.dart';

class Agent {
  final String id;
  final String name;
  final String phoneNumber;
  final String profileImageUrl;
  // final String panCardImageUrl;
  // final String aadharFrontImageUrl;
  // final String aadharBackImageUrl;
  final Timestamp timestamp;
  Agent({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.profileImageUrl,
    // required this.panCardImageUrl,
    // required this.aadharFrontImageUrl,
    // required this.aadharBackImageUrl,
    required this.timestamp,
  });
}
