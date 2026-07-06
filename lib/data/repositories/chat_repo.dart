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
        (await firebaseStore.collection('User').doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firebaseStore.collection('User').doc(otherUserId).get()).data()
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
}
