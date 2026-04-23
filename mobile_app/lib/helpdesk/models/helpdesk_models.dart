enum AppRole { admin, technicien, user }

enum TicketStatus { open, inProgress, closed }

enum TicketPriority { low, medium, high, urgent }

class TicketComment {
  const TicketComment({required this.author, required this.time, required this.message});
  final String author;
  final String time;
  final String message;
}

class Ticket {
  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.date,
    required this.assignedUser,
    required this.comments,
  });

  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String date;
  final String assignedUser;
  final List<TicketComment> comments;
}

class AlertItem {
  const AlertItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
  });
  final String title;
  final String subtitle;
  final String time;
  final bool unread;
}
