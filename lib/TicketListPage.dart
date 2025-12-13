import 'package:flutter/material.dart';

// Sample Ticket Model
class Ticket {
  final String title;
  final String description;
  final String status;
  final String priority;

  Ticket({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
  });
}

class TicketListPage extends StatelessWidget {
   TicketListPage({super.key});

  // Sample data
  final List<Ticket> tickets =  [
    Ticket(
        title: "Login Issue",
        description: "Cannot login to account",
        status: "Open",
        priority: "High"),
    Ticket(
        title: "Bug in Payment",
        description: "Payment fails intermittently",
        status: "In Progress",
        priority: "Medium"),
    Ticket(
        title: "Feature Request",
        description: "Add dark mode",
        status: "Resolved",
        priority: "Low"),
    Ticket(
        title: "App Crash",
        description: "App crashes on launch",
        status: "Open",
        priority: "High"),
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.redAccent;
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tickets"),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: size.width < 600
            ? ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return TicketCard(ticket: ticket);
          },
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return TicketCard(ticket: ticket);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Ticket page
        },
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({super.key, required this.ticket});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.redAccent;
      case 'In Progress':
        return Colors.orangeAccent;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ticket.description,
                style: const TextStyle(color: Colors.black54)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                        color: _getStatusColor(ticket.status),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  ticket.priority,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}