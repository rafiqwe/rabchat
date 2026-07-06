import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rabchats/data/model/chat_message_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.receiverName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 8, // Replace with the actual number of messages
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: ChatMessageModel(
                    id: 'dsasadw2324',
                    chatRoomId: 'chatRoomId',
                    senderId: 'senderId',
                    receiverId: 'receiverId',
                    content:
                        ' Hey this is first lookHey this is first lookHey this is first lookHey this is first look',
                    timestamp: Timestamp.now(),
                    readBy: [],
                  ),
                  isMe:
                      index % 2 ==
                      0, // Replace with actual logic to determine if the message is from the current user
                  isRead: true,
                );
              },
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(24)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isRead,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool showTime = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: widget.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showTime = !showTime;
              });
            },
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                margin: EdgeInsets.only(
                  left: widget.isMe ? 64 : 8,
                  right: widget.isMe ? 8 : 64,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.isMe ? Colors.blue[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  widget.message.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          if (!widget.isMe && showTime == true)
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                '${widget.message.timestamp.toDate().hour}:${widget.message.timestamp.toDate().minute}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

          if (widget.isMe && showTime == true)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: widget.isRead ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.message.timestamp.toDate().hour}:${widget.message.timestamp.toDate().minute}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
