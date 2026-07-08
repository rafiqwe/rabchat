import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabchats/data/repositories/chat_repo.dart';
import 'package:rabchats/logic/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  final String currentUserId;

  ChatCubit({required ChatRepo chatRepo, required this.currentUserId})
    : _chatRepo = chatRepo,
      super(const ChatState());

  void enterChat(String receiverId) async {
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
    } catch (e) {
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
}
