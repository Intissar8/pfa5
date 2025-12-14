import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TicketCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.onDelete,
    required this.onEdit,
  });

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
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.indigo),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  priority,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
