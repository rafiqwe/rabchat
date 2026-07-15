// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:rabchats/data/model/chat_message_model.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessageModel> messages;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.messages = const [],
    this.chatRoomId,
  });
  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessageModel>? messages,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props {
    return [status, error, receiverId, chatRoomId, messages];
  }
}
