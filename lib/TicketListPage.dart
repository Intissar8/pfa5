import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'widgets/ticket_card.dart';

class TicketListPage extends StatelessWidget {
  TicketListPage({super.key});

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // CREATE TICKET
  Future<void> createTicket({
    required String title,
    required String description,
    required String priority,
  }) async {
    await FirebaseFirestore.instance.collection('tickets').add({
      'title': title,
      'description': description,
      'status': 'Open',
      'priority': priority,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  Future<void> updateTicket({
    required String ticketId,
    required String title,
    required String description,
    required String priority,
  }) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .update({
      'title': title,
      'description': description,
      'priority': priority,
    });
  }


  // CREATE TICKET DIALOG
  void _showCreateTicketDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String priority = 'Low';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (value) => priority = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty) {
                return;
              }

              await createTicket(
                title: titleController.text,
                description: descriptionController.text,
                priority: priority,
              );

              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  void _showEditTicketDialog(
      BuildContext context,
      String ticketId,
      String currentTitle,
      String currentDescription,
      String currentPriority,
      ) {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController =
    TextEditingController(text: currentDescription);
    String priority = currentPriority;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (value) => priority = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await updateTicket(
                ticketId: ticketId,
                title: titleController.text,
                description: descriptionController.text,
                priority: priority,
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
      appBar: AppBar(title: const Text("My Tickets")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('ownerId', isEqualTo: uid)
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
                    onDelete: () async {
                      await FirebaseFirestore.instance
                          .collection('tickets')
                          .doc(doc.id)
                          .delete();
                    },
                    onEdit: () {
                      _showEditTicketDialog(
                        context,
                        doc.id,
                        data['title'],
                        data['description'],
                        data['priority'],
                      );
                    },
                  );
                },
              );
            },
          );


        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTicketDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
