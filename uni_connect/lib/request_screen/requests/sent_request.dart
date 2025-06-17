import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SentRequests extends StatefulWidget {
  final String userId;

  const SentRequests({Key? key, required this.userId}) : super(key: key);

  @override
  _SentRequestsState createState() => _SentRequestsState();
}

class _SentRequestsState extends State<SentRequests> {
  List<dynamic> requests = [];
  bool isLoading = true;
  String? error;
  Set<String> processingRequests = {};

  @override
  void initState() {
    super.initState();
    fetchSentRequests();
  }

  Future<void> fetchSentRequests() async {
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
            requests = (decoded['data'] as List)
                .where((item) => item['requested_by'] == 'i_sent')
                .toList();
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

  Future<void> cancelRequest(String requestId) async {
    final url = Uri.parse('https://devtechtop.com/store/public/api/cancel/scholar_request');

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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(child: Text(error!))
            : requests.isEmpty
            ? const Center(child: Text('No sent requests found.'))
            : SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: DataTable(
                  columnSpacing: 32,
                  headingRowColor: MaterialStateProperty.all(
                      Colors.grey.shade200),
                  dataRowHeight: 60,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(label: Text('Receiver Name')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: requests.map((request) {
                    final requestId = request['id'];
                    final isProcessing = processingRequests.contains(requestId);
                    final status = request['status'];
                    final statusColor = status == 'pending'
                        ? Colors.orange
                        : status == 'accepted'
                        ? Colors.green
                        : Colors.red;

                    return DataRow(cells: [
                      DataCell(Text(request['reciever_name'] ?? '')),
                      DataCell(
                        Text(
                          '${status[0].toUpperCase()}${status.substring(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      DataCell(
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () => cancelRequest(requestId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text('Cancel'),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
