import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomInputbar extends StatelessWidget {
  final Color primary;
  final TextEditingController messageController;
  final ValueListenable<bool> _hasText;
  final Future<void> Function() _handleSendMessage; // Fixed function signature

  const CustomInputbar({
    super.key,
    required this.primary,
    required this.messageController,
    required ValueListenable<bool> hasText, // Fixed naming convention
    required Future<void> Function() handleSendMessage,
  }) : _hasText = hasText,
       _handleSendMessage = handleSendMessage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(8),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Aligns elements vertically
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
                          hintText: 'Type a message',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                    onTap: hasText
                        ? _handleSendMessage
                        : null, // Set to null to disable tap visually
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
