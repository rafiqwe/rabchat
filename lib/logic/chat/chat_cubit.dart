import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabchats/data/repositories/chat_repo.dart';
import 'package:rabchats/logic/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  final String currentUserId;
  StreamSubscription? _messageSubscription;
  bool _isInChat = false;

  ChatCubit({required ChatRepo chatRepo, required this.currentUserId})
    : _chatRepo = chatRepo,
      super(const ChatState());

  void enterChat(String receiverId) async {
    _isInChat = true;
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final chatRoom = await _chatRepo.getOrCreateChatRoom(
        currentUserId,
        receiverId,
      );
      emit(
        state.copyWith(
          status: ChatStatus.loaded,
          chatRoomId: chatRoom.id,
          receiverId: receiverId,
        ),
      );
      _subscriptToMessage(chatRoom.id);
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: "Failed to enter or create chat room.",
        ),
      );
    }
  }

  Future<void> sendMessge({
    required String content,
    required String receiverId,
  }) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepo.sendMessage(
        chatRoomId: state.chatRoomId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      emit(state.copyWith(error: "Failed to send message"));
    }
  }

  void _subscriptToMessage(String chatRoomId) {
    _messageSubscription?.cancel();
    _messageSubscription = _chatRepo
        .getMessage(chatRoomId)
        .listen(
          (message) {
            if (_isInChat) {
              _markMessagesAsRead(chatRoomId);
            }
            emit(state.copyWith(messages: message, error: null));
          },
          onError: (error) {
            emit(
              state.copyWith(
                error: "Failed to load message",
                status: ChatStatus.error,
              ),
            );
          },
        );
  }

  Future<void> _markMessagesAsRead(String chatRoomId) async {
    try {
      await _chatRepo.markMessagesAsRead(chatRoomId, currentUserId);
    } catch (e) {
      log('Error marking messages as read: $e');
    }
  }

  Future<void> leaveChat() async {
    _isInChat = false;
  }
}
