import 'package:mobile_app/models/app_models.dart';

List<AppNotification> mockNotifications = [
  AppNotification(
    id: 'n1',
    title: 'SLA breached - INC-10031',
    body: 'Resolution SLA exceeded by 25 minutes. Escalation recommended.',
    ticketId: 'INC-10031',
    ticketTitle: 'Production database read replica lag exceeding 90 seconds',
    priority: Priority.critical,
    event: EventType.slaBreach,
    channel: Channel.inApp,
    role: AppRole.supervisor,
    timeAgo: '3m ago',
    actor: 'System',
  ),
  AppNotification(
    id: 'n2',
    title: 'SLA due in 45 minutes',
    body: 'Update requester or escalate to Network L2.',
    ticketId: 'INC-10042',
    ticketTitle: 'VPN connection drops every 10 minutes from Lyon office',
    priority: Priority.high,
    event: EventType.slaWarning,
    channel: Channel.email,
    role: AppRole.technician,
    timeAgo: '12m ago',
    actor: 'System',
  ),
  AppNotification(
    id: 'n3',
    title: 'Your ticket was solved',
    body: 'Marcus Okonkwo marked INC-10027 as solved.',
    ticketId: 'INC-10027',
    ticketTitle: 'MFA reset for executive assistant',
    priority: Priority.high,
    event: EventType.statusChanged,
    channel: Channel.email,
    role: AppRole.requester,
    timeAgo: '1h ago',
    read: true,
    actor: 'Marcus Okonkwo',
  ),
];

List<SlaTicket> mockSlaTickets = [
  SlaTicket(
    id: 'INC-10031',
    title: 'Production database read replica lag exceeding 90 seconds',
    assignee: 'Priya Iyer',
    group: 'IT - Operations',
    priority: Priority.critical,
    status: TicketStatus.inProgress,
    slaLabel: 'Overdue by 25 min',
    overdue: true,
  ),
  SlaTicket(
    id: 'INC-10042',
    title: 'VPN connection drops every 10 minutes from Lyon office',
    assignee: 'Marcus Okonkwo',
    group: 'IT - Network',
    priority: Priority.high,
    status: TicketStatus.inProgress,
    slaLabel: 'Due in 45 min',
    overdue: false,
  ),
  SlaTicket(
    id: 'INC-10039',
    title: 'Outlook crashes on launch after Windows update',
    assignee: 'Marcus Okonkwo',
    group: 'IT - Endpoint',
    priority: Priority.medium,
    status: TicketStatus.pending,
    slaLabel: 'Due in 2h 20m',
    overdue: false,
  ),
];

List<NotificationRule> mockRules = [
  NotificationRule(
    id: 'r1',
    name: 'Critical incidents -> on-call supervisor',
    enabled: true,
    trigger: EventType.ticketCreated,
    recipients: ['Assignee', 'Group', 'Manager'],
    channels: [Channel.inApp, Channel.email, Channel.sms],
    editedAt: '2d ago',
  ),
  NotificationRule(
    id: 'r2',
    name: 'SLA warning at T-30 minutes',
    enabled: true,
    trigger: EventType.slaWarning,
    recipients: ['Assignee'],
    channels: [Channel.inApp, Channel.email],
    editedAt: '5d ago',
  ),
];

List<NotificationTemplate> mockTemplates = [
  NotificationTemplate(
    id: 'tpl1',
    name: 'Critical ticket created',
    eventLabel: 'Ticket created',
    roleLabel: 'Technician',
    language: 'EN',
    subject: '[{{ticket_id}}] Critical - {{title}}',
    body: 'A critical ticket was just created and routed to your group.',
  ),
  NotificationTemplate(
    id: 'tpl2',
    name: 'SLA warning - 30 min',
    eventLabel: 'SLA warning',
    roleLabel: 'Technician',
    language: 'EN',
    subject: '{{ticket_id}} - SLA due in 30 minutes',
    body: 'Heads up: ticket is due soon. Update requester or escalate.',
  ),
];

List<DeliveryLog> mockLogs = [
  DeliveryLog(
    id: 'dl1',
    ticketId: 'INC-10031',
    recipient: 'priya.iyer@acme.eu',
    channel: Channel.email,
    template: 'tpl_sla_breach',
    status: DeliveryStatus.delivered,
    attempts: 1,
    sentAt: '3m ago',
  ),
  DeliveryLog(
    id: 'dl2',
    ticketId: 'INC-10031',
    recipient: '+33 6 12 34 56 78',
    channel: Channel.sms,
    template: 'tpl_sla_breach',
    status: DeliveryStatus.failed,
    attempts: 2,
    sentAt: '3m ago',
    errorReason: 'SMS gateway timeout (504).',
  ),
];
