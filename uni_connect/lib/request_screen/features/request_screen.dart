import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SendRequestScreen extends StatefulWidget {
  final String senderId;

  const SendRequestScreen({required this.senderId, Key? key}) : super(key: key);

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  List<dynamic> allUsers = [];
  List<String> sentToIds = [];
  bool isLoading = false;
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://devtechtop.com/store/public/api/all_user'); // check spelling

    print('Sending user_id: ${widget.senderId}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': widget.senderId}),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          allUsers = data['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to load users')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  Future<void> sendRequest(String receiverId) async {
    final response = await http.post(
      Uri.parse('https://devtechtop.com/store/public/api/scholar_request/insert'),
      body: {
        'sender_id': widget.senderId,
        'receiver_id': receiverId,
        'description': descriptionController.text.trim(),
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        sentToIds.add(receiverId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request sent successfully!")),
      );
    } else {
      final errors = data['errors'];
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text(errors.toString()),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Widget buildUserCard(dynamic user) {
    final receiverId = user['id'];
    final alreadySent = sentToIds.contains(receiverId);
    final status = user['if_request'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 4,
      child: ListTile(
        title: Text(user['name']),
        subtitle: Text("${user['degree']} - ${user['shift']}"),
        trailing: alreadySent || status == "pending"
            ? const Text("Pending", style: TextStyle(color: Colors.orange))
            : IconButton(
          icon: const Icon(Icons.send),
          onPressed: () => sendRequest(receiverId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Request"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: allUsers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) =>
                  buildUserCard(allUsers[index]),
            ),
          ),
        ],
      ),
    );
  }
}
