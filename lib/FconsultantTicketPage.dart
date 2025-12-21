import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfa5/AuthPage.dart';
import 'widgets/ticket_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FconsultantTicketPage extends StatelessWidget {
  FconsultantTicketPage({super.key});

  // UPDATE TICKET STATUS ONLY
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
    String? department,
    String? priority,
  }) async {
    Map<String, dynamic> updateData = {'status': status};

    if (department != null) updateData['department'] = department;
    if (priority != null) updateData['priority'] = priority;

    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update(updateData);
  }


  Future<Map<String, dynamic>> classifyTicket(String text) async {
    final url = Uri.parse("http://192.168.1.9:8000/classify_ticket");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to classify ticket: ${response.statusCode}");
    }
  }

  // SHOW STATUS EDIT DIALOG
  void _showEditStatusDialog(
      BuildContext context,
      String ticketId,
      String currentStatus,
      ) {
    String status = currentStatus;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Update Status', style: TextStyle(color: Colors.black)),
        content: DropdownButtonFormField<String>(
          value: status,
          decoration: const InputDecoration(
            labelText: 'Status',
            prefixIcon: Icon(Icons.info),
          ),
          items: const [
            DropdownMenuItem(value: 'Open', child: Text('Open')),
            DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
            DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
          ],
          onChanged: (value) => status = value!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await updateTicketStatus(
                ticketId: ticketId,
                status: status,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tickets"),
        actions: [
          IconButton(
            onPressed: () async {
              await   FirebaseAuth.instance.signOut();
              // After logout, navigate back to login page
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
                // make sure your AuthPage has a named route '/auth'
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: Colors.deepPurple, // modern color
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading tickets"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No tickets yet"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;

              if (constraints.maxWidth > 1200) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return TicketCard(
                    id: doc.id,
                    title: data['title'],
                    description: data['description'],
                    status: data['status'],
                    priority: data['priority'],
                    department: data['department'],
                    onDelete: null, // Consultant cannot delete
                    onEdit: () {
                      _showEditStatusDialog(
                        context,
                        doc.id,
                        data['status'],
                      );
                    },
                    extraButton: ElevatedButton.icon(
                      icon: const Icon(Icons.support_agent, size: 18),
                      label: const Text("Consult Agent"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () async {
                        try {
                          final result = await classifyTicket(data['description']);

                          // Update Firestore with classified department and priority
                          await updateTicketStatus(
                            ticketId: doc.id,
                            status: data['status'], // keep current status
                            department: result['department'],
                            priority: result['priority'],
                          );

                          // Show result in a dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Classification Result"),
                              content: Text(
                                  "Department: ${result['department']}\n"
                                      "Priority: ${result['priority']}"
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
