// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rabchats/core/common/custom_InputBar.dart';
import 'package:rabchats/data/model/chat_message_model.dart';
import 'package:rabchats/data/services/service_loactor.dart';
import 'package:rabchats/logic/chat/chat_cubit.dart';
import 'package:rabchats/logic/chat/chat_state.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatMessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  late final ChatCubit _chatCubit;

  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(() {
      _hasText.value = messageController.text.trim().isNotEmpty;
    });
    super.initState();
  }

  Future<void> _handleSendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;
    messageController.clear();

    await _chatCubit.sendMessge(
      content: messageText,
      receiverId: widget.receiverId,
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        backgroundColor: primary,
        title: Row(
          children: [
            Hero(
              tag: 'avatar_${widget.receiverId}',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                child: Text(
                  widget.receiverName.isNotEmpty
                      ? widget.receiverName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.greenAccent,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ChatStatus.error) {
            return Center(
              child: Text(
                state.error ?? 'Something went wrong',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state.messages.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Say hello 👋\nNo messages yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45, fontSize: 15),
                    ),
                  ),
                ),
                _buildInputBar(primary),
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 6,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == _chatCubit.currentUserId;
                    final isRead = message.status == MessageStatus.read;

                    // Group consecutive messages from the same sender
                    final isLastInGroup =
                        index == 0 ||
                        state.messages[index - 1].senderId != message.senderId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showTail: isLastInGroup,
                      isRead: isRead,
                    );
                  },
                ),
              ),
              CustomInputbar(
                primary: primary,
                messageController: messageController,
                hasText: _hasText,
                handleSendMessage: _handleSendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar(Color primary) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        controller: messageController,
                        style: const TextStyle(fontSize: 15.5),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            ValueListenableBuilder<bool>(
              valueListenable: _hasText,
              builder: (context, hasText, _) {
                return Material(
                  color: primary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: hasText ? _handleSendMessage : () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        hasText ? Icons.send : Icons.mic_none,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool isRead;
  final bool showTail;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isRead = false,
    this.showTail = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool showTime = false;

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final bubbleColor = isMe ? const Color(0xFFDCF8C6) : Colors.white;
    final time = widget.message.timestamp.toDate();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => showTime = !showTime),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  margin: EdgeInsets.only(
                    left: isMe ? 60 : 8,
                    right: isMe ? 8 : 60,
                    top: 2,
                    bottom: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(
                        isMe || !widget.showTail ? 14 : 2,
                      ),
                      bottomRight: Radius.circular(
                        isMe && widget.showTail ? 2 : 14,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message.content,
                        style: const TextStyle(fontSize: 15.5, height: 1.3),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(time),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              widget.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: widget.isRead
                                  ? Colors.lightBlue
                                  : Colors.black45,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
