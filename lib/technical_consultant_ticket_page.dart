import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfa5/AuthPage.dart';
import 'widgets/ticket_card.dart';

class TechnicalConsultantTicketPage extends StatelessWidget {
  const TechnicalConsultantTicketPage({super.key});

  // UPDATE ONLY STATUS
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update({
      'status': status,
    });
  }

  // STATUS DIALOG
  void _showStatusDialog(
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
        title: const Text(
          'Update Status',
          style: TextStyle(color: Colors.black),
        ),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Technical Tickets"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('department', isEqualTo: 'Technical')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No technical tickets"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;

              if (constraints.maxWidth >= 1400) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth >= 1100) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 800) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth >= 500) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
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
                    onDelete: null,
                    onEdit: () {
                      _showStatusDialog(
                        context,
                        doc.id,
                        data['status'],
                      );
                    },
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
