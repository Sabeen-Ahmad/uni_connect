import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uni_connect/request_screen/services/chat_screen.dart';

class AcceptedFriendsScreen extends StatefulWidget {
  final String userId;

  const AcceptedFriendsScreen({super.key, required this.userId});

  @override
  State<AcceptedFriendsScreen> createState() => _AcceptedFriendsScreenState();
}

class _AcceptedFriendsScreenState extends State<AcceptedFriendsScreen> {
  List friends = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAcceptedFriends();
  }

  Future<void> fetchAcceptedFriends() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/api/accepted/scholar_request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': widget.userId}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() => friends = data['data']);
      } else {
        showMessage(data['message'] ?? "Something went wrong");
      }
    } else {
      showMessage("Server error: ${response.statusCode}");
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void openChatScreen(Map friend) {
    final isISent = friend['requested_by'] == 'i_sent';

    final chatItem = {
      'chat_id': friend['chat_id'],
      'sender_id': friend['sender_id'],
      'receiver_id': friend['receiver_id'],
      'sender_name': friend['sender_name'],
      'reciever_name': friend['reciever_name'],
      'requested_by': friend['requested_by'],
    };

    final loggedInUserId = isISent ? friend['sender_id'] : friend['receiver_id'];
    final loggedInUserName = isISent ? friend['sender_name'] : friend['reciever_name'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatData: chatItem,
          loggedInUserId: loggedInUserId,
          loggedInUserName: loggedInUserName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? const Center(child: Text("No accepted friends found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1.5),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Friend Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Friend Rows
                ...friends.map<TableRow>((friend) {
                  final isISent = friend['requested_by'] == 'i_sent';
                  final receiverName =
                  isISent ? friend['reciever_name'] : friend['sender_name'];

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(receiverName ?? 'Unknown'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () => openChatScreen(friend),
                          child: const Text("Chat"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
