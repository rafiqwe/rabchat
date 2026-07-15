import 'package:flutter/material.dart';
import 'package:rabchats/data/model/chat_model.dart';
import 'package:rabchats/data/repositories/chat_repo.dart';
import 'package:rabchats/data/services/service_loactor.dart'; // Fixed typo if it matches your project structure: service_locator.dart

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  String _getOtherUsername() {
    // 1. Guard against empty participants lists entirely
    if (chat.perticipants.isEmpty) {
      return 'Unknown User';
    }

    // 2. Safe fallback if you are the only participant (e.g., Note to Self)
    final otherUserId = chat.perticipants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    // 3. Handle nullable map protection
    if (chat.perticipantsName == null) return 'Unknown User';

    return chat.perticipantsName![otherUserId] ?? 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final username =
        _getOtherUsername(); // Caching string so we don't recalculate 3 times

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.lastMessage ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: StreamBuilder<int>(
        // Added explicit type to the StreamBuilder
        stream: getIt<ChatRepo>().getUnReadCount(chat.id, currentUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == 0) {
            return const SizedBox();
          }

          return Container(
            padding: const EdgeInsets.all(
              6,
            ), // Dynamic padding works much better for double/triple digits
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              snapshot.data.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:
                    11, // Slightly smaller font so double digits fit perfectly inside a minimal badge
              ),
            ),
          );
        },
      ),
    );
  }
}
