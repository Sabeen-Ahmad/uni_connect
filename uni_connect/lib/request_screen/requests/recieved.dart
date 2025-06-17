
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceivedRequests extends StatefulWidget {
  final String userId;

  const ReceivedRequests({Key? key, required this.userId}) : super(key: key);

  @override
  _ReceivedRequestsState createState() => _ReceivedRequestsState();
}

class _ReceivedRequestsState extends State<ReceivedRequests> {
  List<dynamic> requests = [];
  bool isLoading = true;
  String? error;
  Set<String> processingRequests = {}; // to track buttons being pressed

  @override
  void initState() {
    super.initState();
    fetchMyRequests();
  }

  Future<void> fetchMyRequests() async {
    final url = Uri.parse('https://devtechtop.com/store/public/api/scholar_request/all');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);

        if (decoded['status'] == 'success') {
          setState(() {
            requests = decoded['data'] ?? [];
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'API returned an error.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to load data. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> acceptRequest(String requestId) async {
    final url = Uri.parse('https://devtechtop.com/store/public/api/update/scholar_request'); // replace with actual accept API URL

    setState(() {
      processingRequests.add(requestId);
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_id': requestId}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['message'] ?? 'Request accepted')),
        );
        // Update local request status to accepted
        setState(() {
          final index = requests.indexWhere((r) => r['id'] == requestId);
          if (index != -1) {
            requests[index]['status'] = 'accepted';
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['message'] ?? 'Failed to accept request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        processingRequests.remove(requestId);
      });
    }
  }

  Future<void> cancelRequest(String requestId) async {
    final url = Uri.parse('https://devtechtop.com/store/public/api/cancel/scholar_request'); // replace with actual cancel API URL

    setState(() {
      processingRequests.add(requestId);
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'request_id': requestId}),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && decoded['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['message'] ?? 'Request canceled')),
        );
        // Remove canceled request from list
        setState(() {
          requests.removeWhere((r) => r['id'] == requestId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(decoded['message'] ?? 'Failed to cancel request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        processingRequests.remove(requestId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade100,
        foregroundColor: Colors.indigo.shade900,
        title: const Text('My Requests'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : requests.isEmpty
          ? const Center(child: Text('No requests found.'))
          : SingleChildScrollView(
          scrollDirection: Axis.horizontal, // allow horizontal scrolling if needed
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Receiver')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Requested By')),
              DataColumn(label: Text('Entry Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: requests.map((request) {
              final requestId = request['id'] as String;
              final status = request['status'] as String? ?? '';
              final isProcessing = processingRequests.contains(requestId);

              return DataRow(cells: [
                DataCell(Text(request['reciever_name'] ?? '')),
                DataCell(Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'accepted'
                        ? Colors.green
                        : (status == 'pending' ? Colors.orange : Colors.red),
                  ),
                )),
                DataCell(Text(request['requested_by'] ?? '')),
                DataCell(Text(request['entry_date_time'] ?? 'N/A')),
                DataCell(
                  status == 'pending'
                      ? Row(
                    children: [
                      ElevatedButton(
                        onPressed: isProcessing ? null : () => acceptRequest(requestId),
                        child: isProcessing
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Accept'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isProcessing ? null : () => cancelRequest(requestId),
                        child: isProcessing
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Cancel'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  )
                      : const Text('No actions'),
                ),
              ]);
            }).toList(),
          )

      ),
    );
  }

}