import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;

  final List<String> perticipants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageSenderTime;
  final Map<String, Timestamp>? lastReadTime;
  final Map<String, String>? perticipantsName;
  final bool isTyping;
  final String? typingUserId;
  final bool isCallActive;

  ChatRoomModel({
    required this.id,
    required this.perticipants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageSenderTime,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? perticipantsName,
    this.isTyping = false,
    this.typingUserId,
    this.isCallActive = false,
  }) : lastReadTime = lastReadTime ?? {},
       perticipantsName = perticipantsName ?? {};

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      perticipants: List.from(data['perticipants']),
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageSenderTime: data['lastMessageSenderTime'],
      lastReadTime: Map<String, Timestamp>.from(data['lastReadTime']),
      perticipantsName:
          Map<String, String>.from(data['perticipantsName']),
      isTyping: data['isTyping'] ?? false,
      typingUserId: data['typingUserId'],
      isCallActive: data['isCallActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'perticipants': perticipants,
      'lastMessage': lastMessage,
      "lastMessageSenderId": lastMessageSenderId,
      'lastReadTime': lastReadTime,
      'perticipantsName': perticipantsName,
      "isTyping": isTyping,
      'typingUserId': typingUserId,
      'isCallActive': isCallActive,
      'lastMessageSenderTime': lastMessageSenderTime,
    };
  }
}
