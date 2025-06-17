import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/message_stream.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final String loggedInUserId;
  final String loggedInUserName;

  const ChatScreen({
    Key? key,
    required this.chatData,
    required this.loggedInUserId,
    required this.loggedInUserName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String messageText = "";

  late final String chatId;
  late final String senderId;
  late final String receiverId;
  late String senderName;
  late String receiverName;

  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final data = widget.chatData;

    chatId = data['chat_id'];
    senderId = data['sender_id'];
    receiverId = data['receiver_id'];

    // Determine roles dynamically
    if (widget.loggedInUserId == senderId) {
      senderName = widget.loggedInUserName;
      receiverName = data['receiver_name'] ?? 'Receiver';
    } else {
      senderName = data['receiver_name'] ?? 'Sender';
      receiverName = widget.loggedInUserName;
    }
  }

  void sendMessage() async {
    final trimmedText = messageText.trim();
    if (trimmedText.isEmpty) return;

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);

      final messageData = {
        'text': trimmedText,
        'sender_id': widget.loggedInUserId,
        'receiver_id': widget.loggedInUserId == senderId ? receiverId : senderId,
        'sender_name': senderName,
        'receiver_name': receiverName,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await chatRef.collection('messages').add(messageData);

      messageController.clear();
      setState(() => messageText = "");
    } catch (e) {
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(receiverName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageStream(
              chatId: chatId,
              loggedInUserId: widget.loggedInUserId,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    onChanged: (value) => setState(() => messageText = value),
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
