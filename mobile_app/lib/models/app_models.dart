enum AppRole { requester, technician, supervisor }

enum Priority { low, medium, high, critical }

enum TicketStatus { open, inProgress, pending, solved, closed }

enum EventType {
  ticketCreated,
  ticketAssigned,
  newFollowUp,
  slaWarning,
  slaBreach,
  statusChanged,
  approvalRequested,
  priorityChanged,
}

enum DeliveryStatus { sent, delivered, opened, failed, queued }

enum Channel { inApp, email, sms }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.ticketId,
    required this.ticketTitle,
    required this.priority,
    required this.event,
    required this.channel,
    required this.role,
    required this.timeAgo,
    this.read = false,
    this.archived = false,
    this.actor,
  });

  final String id;
  final String title;
  final String body;
  final String ticketId;
  final String ticketTitle;
  final Priority priority;
  final EventType event;
  final Channel channel;
  final AppRole role;
  final String timeAgo;
  final String? actor;
  bool read;
  bool archived;
}

class SlaTicket {
  SlaTicket({
    required this.id,
    required this.title,
    required this.assignee,
    required this.group,
    required this.priority,
    required this.status,
    required this.slaLabel,
    required this.overdue,
  });

  final String id;
  final String title;
  final String assignee;
  final String group;
  final Priority priority;
  final TicketStatus status;
  final String slaLabel;
  final bool overdue;
}

class NotificationRule {
  NotificationRule({
    required this.id,
    required this.name,
    required this.enabled,
    required this.trigger,
    required this.recipients,
    required this.channels,
    required this.editedAt,
  });

  final String id;
  final String name;
  bool enabled;
  final EventType trigger;
  final List<String> recipients;
  final List<Channel> channels;
  final String editedAt;
}

class NotificationTemplate {
  NotificationTemplate({
    required this.id,
    required this.name,
    required this.eventLabel,
    required this.roleLabel,
    required this.language,
    required this.subject,
    required this.body,
  });

  final String id;
  final String name;
  final String eventLabel;
  final String roleLabel;
  String language;
  String subject;
  String body;
}

class DeliveryLog {
  DeliveryLog({
    required this.id,
    required this.ticketId,
    required this.recipient,
    required this.channel,
    required this.template,
    required this.status,
    required this.attempts,
    required this.sentAt,
    this.errorReason,
  });

  final String id;
  final String ticketId;
  final String recipient;
  final Channel channel;
  final String template;
  DeliveryStatus status;
  int attempts;
  final String sentAt;
  String? errorReason;
}
