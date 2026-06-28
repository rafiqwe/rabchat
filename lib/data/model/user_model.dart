import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isOnline;
  final Timestamp lastSeen;
  final Timestamp createdAt;
  final String fcmToken;
  final List<String> blockUsers;

  UserModel({
    required this.uid,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.isOnline = false,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    required this.fcmToken,
    this.blockUsers = const [],
  }) : lastSeen = lastSeen ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();

  Map<String, dynamic> toMap(){
    return {
      'username': username,
      'fullName': fullName,
      "email": email,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      "lastSeen": lastSeen,
      'createdAt': createdAt,
      'blockUsers': blockUsers,
      'fcmToken': fcmToken,
    };
}

}
