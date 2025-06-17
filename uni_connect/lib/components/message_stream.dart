import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class MessageStream extends StatelessWidget {
  final String chatId;
  final String loggedInUserId;

  const MessageStream({
    Key? key,
    required this.chatId,
    required this.loggedInUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: messagesRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: false,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            final text = msg['text'] ?? '';
            final timestamp = msg['timestamp'] as Timestamp?;
            final senderId = msg['sender_id'] ?? 'system';

            final isMe = senderId == loggedInUserId;

            return MessageBubble(
              message: text,
              isMe: isMe,
              timestamp: timestamp?.toDate(),
            );
          }

        );
      },
    );
  }
}
