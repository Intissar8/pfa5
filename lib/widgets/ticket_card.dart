import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? department;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? extraButton;

  const TicketCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.department,
    this.onEdit,
    this.onDelete,
    this.extraButton,
  });

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _departmentIcon(String? dept) {
    switch (dept) {
      case 'Technical':
        return Icons.computer;
      case 'Finance':
        return Icons.account_balance;
      case 'Support':
        return Icons.support_agent;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(Icons.confirmation_number, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),


            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 10),


            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.flag,
                    size: 16,
                    color: _priorityColor(priority),
                  ),
                  label: Text(priority),
                ),
                Chip(
                  avatar: const Icon(Icons.timelapse, size: 16),
                  label: Text(status),
                ),
              ],
            ),

            const Spacer(),


            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (extraButton != null) extraButton!,
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

