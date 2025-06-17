import 'package:flutter/material.dart';
import 'package:uni_connect/request_screen/requests/recieved.dart';
import 'package:uni_connect/request_screen/requests/show_accepted_requests.dart';
import 'sent_request.dart';

class RequestsTabScreen extends StatefulWidget {
  final String userId;

  const RequestsTabScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<RequestsTabScreen> createState() => _RequestsTabScreenState();
}

class _RequestsTabScreenState extends State<RequestsTabScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ReceivedRequests(userId: widget.userId),
      SentRequests(userId: widget.userId),
      AcceptedFriendsScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Received',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Sent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Friends',
          ),
        ],
      ),
    );
  }
}
