class Ticket {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String ownerId;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.ownerId,
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data, String id) {
    return Ticket(
      id: id,
      title: data['title'],
      description: data['description'],
      status: data['status'],
      priority: data['priority'],
      ownerId: data['ownerId'],
    );
  }
}
