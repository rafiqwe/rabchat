import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabchats/data/model/chat_message_model.dart';
import 'package:rabchats/data/model/chat_model.dart';
import 'package:rabchats/data/services/auth_repository.dart';

class ChatRepo extends BaseRepository {
  CollectionReference get _chatRooms => firebaseStore.collection('chatRoom');
  CollectionReference getChatRoomsMessages(String roomId) =>
      _chatRooms.doc(roomId).collection('messages');

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomID = users.join('_');
    final roomDoc = await _chatRooms.doc(roomID).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }
    final currentUserData =
        (await firebaseStore.collection('Users').doc(currentUserId).get())
                .data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firebaseStore.collection('Users').doc(otherUserId).get()).data()
            as Map<String, dynamic>;
    final perticipantsName = {
      currentUserId: currentUserData['fullName']?.toString() ?? '',
      otherUserId: otherUserData['fullName']?.toString() ?? '',
    };

    final newRoom = ChatRoomModel(
      id: roomID,
      perticipants: users,
      perticipantsName: perticipantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );
    await _chatRooms.doc(roomID).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final batch = firebaseStore.batch();

      // get message sub collection reference
      final messagesRef = getChatRoomsMessages(chatRoomId);

      final messageDoc = messagesRef.doc();

      final message = ChatMessageModel(
        id: messageDoc.id,
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: Timestamp.now(),
        readBy: [senderId],
      );

      // add message to the messages subcollection
      batch.set(messageDoc, message.toMap());

      // Update the lastReadTime for the sender in the chat room document
      batch.update(_chatRooms.doc(chatRoomId), {
        'lastMessage': content,
        'lastMessageSenderId': senderId,
        'lastMessageSenderTime': message.timestamp,
      });

      await batch.commit();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> getMessage(
    String chatRoomId, {
    DocumentSnapshot? lastDocument,
  }) {
    var query = getChatRoomsMessages(
      chatRoomId,
    ).orderBy('timestamp', descending: true).limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<List<ChatMessageModel>> getMoreMessage(
    String chatRoomId, {
    required DocumentSnapshot lastDocument,
  }) async {
    var query = getChatRoomsMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<ChatRoomModel>> getChatRoom(String userId) {
    return _chatRooms
        .where('perticipants', arrayContains: userId)
        .orderBy('lastMessageSenderTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoomModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<int> getUnReadCount(String chatRoomId, String userId) {
    return getChatRoomsMessages(chatRoomId)
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.send.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    final batch = firebaseStore.batch();

    final messagesRef = getChatRoomsMessages(chatRoomId);
    final unreadMessagesQuery = await messagesRef
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.send.toString())
        .get();

    log("Found ${unreadMessagesQuery.docs.length}");
    

    for (final doc in unreadMessagesQuery.docs) {
      batch.update(doc.reference, {
        'status': MessageStatus.read.toString(),
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }

    await batch.commit();
  }
}
