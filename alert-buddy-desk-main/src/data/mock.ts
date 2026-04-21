export type Role = "requester" | "technician" | "supervisor";

export type Priority = "low" | "medium" | "high" | "critical";

export type TicketStatus =
  | "new"
  | "in_progress"
  | "pending"
  | "solved"
  | "closed";

export type EventType =
  | "ticket_created"
  | "ticket_assigned"
  | "ticket_reassigned"
  | "status_changed"
  | "new_followup"
  | "sla_warning"
  | "sla_breach"
  | "approval_requested"
  | "approval_approved"
  | "approval_rejected"
  | "priority_changed"
  | "ticket_reopened";

export type Channel = "in_app" | "email" | "sms";

export type DeliveryStatus = "sent" | "delivered" | "opened" | "failed" | "queued";

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  role: Role;
  avatar: string;
  group: string;
}

export interface Ticket {
  id: string; // e.g. "INC-10042"
  title: string;
  status: TicketStatus;
  priority: Priority;
  category: string;
  group: string;
  requester: string;
  assignee: string;
  createdAt: string;
  slaDueAt: string;
  lastUpdate: string;
}

export interface Notification {
  id: string;
  event: EventType;
  ticketId: string;
  ticketTitle: string;
  priority: Priority;
  recipient: Role;
  title: string;
  body: string;
  createdAt: string; // ISO
  read: boolean;
  archived: boolean;
  channel: Channel;
  actor?: string;
}

export interface NotificationRule {
  id: string;
  name: string;
  enabled: boolean;
  order: number;
  trigger: EventType;
  conditions: {
    groups?: string[];
    categories?: string[];
    priorities?: Priority[];
    requesterTypes?: ("internal" | "external" | "vip")[];
  };
  recipients: {
    requester: boolean;
    assignee: boolean;
    group: boolean;
    manager: boolean;
    customEmails: string[];
  };
  channels: Channel[];
  template: string;
  lastEdited: string;
  editor: string;
}

export interface NotificationTemplate {
  id: string;
  name: string;
  event: EventType;
  role: Role | "all";
  subject: string;
  body: string; // markdown-ish
  language: "en" | "fr" | "pt";
  updatedAt: string;
}

export interface UserPreferences {
  channels: Record<Channel, boolean>;
  quietHours: { enabled: boolean; from: string; to: string };
  frequency: "instant" | "hourly_digest" | "daily_summary";
  mutedTickets: string[];
  mutedCategories: string[];
  language: "en" | "fr" | "pt";
  timezone: string;
}

export interface DeliveryLog {
  id: string;
  notificationId: string;
  ticketId: string;
  recipient: string;
  channel: Channel;
  template: string;
  status: DeliveryStatus;
  attempts: number;
  errorReason?: string;
  sentAt: string;
  deliveredAt?: string;
  openedAt?: string;
}

const now = Date.now();
const minutes = (n: number) => new Date(now - n * 60_000).toISOString();
const hours = (n: number) => new Date(now - n * 3_600_000).toISOString();
const future = (n: number) => new Date(now + n * 60_000).toISOString();

export const USERS: UserProfile[] = [
  {
    id: "u_req",
    name: "Amélie Roussel",
    email: "amelie.roussel@acme.eu",
    role: "requester",
    avatar: "AR",
    group: "Finance",
  },
  {
    id: "u_tech",
    name: "Marcus Okonkwo",
    email: "marcus.okonkwo@acme.eu",
    role: "technician",
    avatar: "MO",
    group: "IT — Service Desk",
  },
  {
    id: "u_sup",
    name: "Priya Iyer",
    email: "priya.iyer@acme.eu",
    role: "supervisor",
    avatar: "PI",
    group: "IT — Operations",
  },
];

export const TICKETS: Ticket[] = [
  {
    id: "INC-10042",
    title: "VPN connection drops every 10 minutes from Lyon office",
    status: "in_progress",
    priority: "high",
    category: "Network",
    group: "IT — Network",
    requester: "Amélie Roussel",
    assignee: "Marcus Okonkwo",
    createdAt: hours(6),
    slaDueAt: future(45),
    lastUpdate: minutes(12),
  },
  {
    id: "INC-10039",
    title: "Outlook crashes on launch after Windows update KB5039212",
    status: "pending",
    priority: "medium",
    category: "Software",
    group: "IT — Endpoint",
    requester: "Daniel Park",
    assignee: "Marcus Okonkwo",
    createdAt: hours(22),
    slaDueAt: future(180),
    lastUpdate: minutes(48),
  },
  {
    id: "INC-10031",
    title: "Production database read replica lag exceeding 90 seconds",
    status: "in_progress",
    priority: "critical",
    category: "Infrastructure",
    group: "IT — Operations",
    requester: "Sofia Bergman",
    assignee: "Priya Iyer",
    createdAt: hours(2),
    slaDueAt: future(-25),
    lastUpdate: minutes(4),
  },
  {
    id: "REQ-20188",
    title: "New laptop request — incoming hire, Marketing team",
    status: "new",
    priority: "low",
    category: "Hardware",
    group: "IT — Procurement",
    requester: "Hugo Martin",
    assignee: "Unassigned",
    createdAt: minutes(35),
    slaDueAt: future(2400),
    lastUpdate: minutes(35),
  },
  {
    id: "INC-10027",
    title: "MFA reset for executive assistant before 9am board meeting",
    status: "solved",
    priority: "high",
    category: "Identity",
    group: "IT — Service Desk",
    requester: "Lin Wei",
    assignee: "Marcus Okonkwo",
    createdAt: hours(9),
    slaDueAt: future(-120),
    lastUpdate: hours(1),
  },
  {
    id: "INC-10018",
    title: "Printer on 4F not responding — driver error 0x8007007e",
    status: "in_progress",
    priority: "low",
    category: "Hardware",
    group: "IT — Endpoint",
    requester: "Marta Costa",
    assignee: "Jakub Nowak",
    createdAt: hours(30),
    slaDueAt: future(220),
    lastUpdate: hours(3),
  },
];

export const NOTIFICATIONS: Notification[] = [
  {
    id: "n1",
    event: "sla_breach",
    ticketId: "INC-10031",
    ticketTitle: "Production database read replica lag exceeding 90 seconds",
    priority: "critical",
    recipient: "supervisor",
    title: "SLA breached — INC-10031",
    body: "Resolution SLA exceeded by 25 minutes. Escalation to on-call infra lead recommended.",
    createdAt: minutes(3),
    read: false,
    archived: false,
    channel: "in_app",
    actor: "System",
  },
  {
    id: "n2",
    event: "new_followup",
    ticketId: "INC-10042",
    ticketTitle: "VPN connection drops every 10 minutes from Lyon office",
    priority: "high",
    recipient: "technician",
    title: "Amélie Roussel added a follow-up",
    body: "“Tried the new client build, drop happens after exactly 10 min on both 4G and office LAN.”",
    createdAt: minutes(12),
    read: false,
    archived: false,
    channel: "in_app",
    actor: "Amélie Roussel",
  },
  {
    id: "n3",
    event: "sla_warning",
    ticketId: "INC-10042",
    ticketTitle: "VPN connection drops every 10 minutes from Lyon office",
    priority: "high",
    recipient: "technician",
    title: "SLA due in 45 minutes",
    body: "Resolution target 16:30 CET. Update the requester or escalate to Network L2.",
    createdAt: minutes(20),
    read: false,
    archived: false,
    channel: "in_app",
    actor: "System",
  },
  {
    id: "n4",
    event: "ticket_assigned",
    ticketId: "REQ-20188",
    ticketTitle: "New laptop request — incoming hire, Marketing team",
    priority: "low",
    recipient: "technician",
    title: "Ticket assigned to your group",
    body: "REQ-20188 routed to IT — Procurement. No assignee yet.",
    createdAt: minutes(35),
    read: true,
    archived: false,
    channel: "email",
  },
  {
    id: "n5",
    event: "approval_requested",
    ticketId: "REQ-20188",
    ticketTitle: "New laptop request — incoming hire, Marketing team",
    priority: "low",
    recipient: "supervisor",
    title: "Approval requested — €1,840 hardware",
    body: "Hugo Martin requested a MacBook Pro 14” for new hire. Awaiting your approval.",
    createdAt: minutes(36),
    read: false,
    archived: false,
    channel: "in_app",
    actor: "Hugo Martin",
  },
  {
    id: "n6",
    event: "status_changed",
    ticketId: "INC-10027",
    ticketTitle: "MFA reset for executive assistant before 9am board meeting",
    priority: "high",
    recipient: "requester",
    title: "Your ticket was solved",
    body: "Marcus Okonkwo marked INC-10027 as Solved. Confirm or reopen within 48 hours.",
    createdAt: hours(1),
    read: true,
    archived: false,
    channel: "email",
    actor: "Marcus Okonkwo",
  },
  {
    id: "n7",
    event: "priority_changed",
    ticketId: "INC-10039",
    ticketTitle: "Outlook crashes on launch after Windows update KB5039212",
    priority: "medium",
    recipient: "technician",
    title: "Priority raised to Medium",
    body: "Affecting 6 users in Finance. Bumped from Low by Priya Iyer.",
    createdAt: hours(2),
    read: true,
    archived: false,
    channel: "in_app",
    actor: "Priya Iyer",
  },
  {
    id: "n8",
    event: "ticket_reopened",
    ticketId: "INC-10018",
    ticketTitle: "Printer on 4F not responding — driver error 0x8007007e",
    priority: "low",
    recipient: "technician",
    title: "Marta Costa reopened the ticket",
    body: "“Same error returned this morning after restart. Sending screenshot.”",
    createdAt: hours(3),
    read: true,
    archived: false,
    channel: "in_app",
    actor: "Marta Costa",
  },
  {
    id: "n9",
    event: "ticket_created",
    ticketId: "INC-10042",
    ticketTitle: "VPN connection drops every 10 minutes from Lyon office",
    priority: "high",
    recipient: "technician",
    title: "New high-priority ticket in your group",
    body: "Created by Amélie Roussel · Network · auto-routed by category rule.",
    createdAt: hours(6),
    read: true,
    archived: false,
    channel: "in_app",
    actor: "Amélie Roussel",
  },
];

export const RULES: NotificationRule[] = [
  {
    id: "r1",
    name: "Critical incidents → on-call supervisor",
    enabled: true,
    order: 1,
    trigger: "ticket_created",
    conditions: { priorities: ["critical"], groups: ["IT — Operations", "IT — Network"] },
    recipients: { requester: false, assignee: true, group: true, manager: true, customEmails: ["oncall@acme.eu"] },
    channels: ["in_app", "email", "sms"],
    template: "tpl_critical_created",
    lastEdited: hours(48),
    editor: "Priya Iyer",
  },
  {
    id: "r2",
    name: "SLA warning at T-30 minutes",
    enabled: true,
    order: 2,
    trigger: "sla_warning",
    conditions: { priorities: ["high", "critical"] },
    recipients: { requester: false, assignee: true, group: false, manager: false, customEmails: [] },
    channels: ["in_app", "email"],
    template: "tpl_sla_warning",
    lastEdited: hours(120),
    editor: "Priya Iyer",
  },
  {
    id: "r3",
    name: "SLA breach → escalate to manager",
    enabled: true,
    order: 3,
    trigger: "sla_breach",
    conditions: {},
    recipients: { requester: false, assignee: true, group: true, manager: true, customEmails: [] },
    channels: ["in_app", "email"],
    template: "tpl_sla_breach",
    lastEdited: hours(72),
    editor: "Priya Iyer",
  },
  {
    id: "r4",
    name: "Solved ticket → notify requester for confirmation",
    enabled: true,
    order: 4,
    trigger: "status_changed",
    conditions: {},
    recipients: { requester: true, assignee: false, group: false, manager: false, customEmails: [] },
    channels: ["email"],
    template: "tpl_solved_requester",
    lastEdited: hours(240),
    editor: "Marcus Okonkwo",
  },
  {
    id: "r5",
    name: "Hardware approval > €1,500 → finance manager",
    enabled: false,
    order: 5,
    trigger: "approval_requested",
    conditions: { categories: ["Hardware"] },
    recipients: { requester: false, assignee: false, group: false, manager: true, customEmails: ["finance.approvals@acme.eu"] },
    channels: ["email"],
    template: "tpl_approval_request",
    lastEdited: hours(500),
    editor: "Priya Iyer",
  },
];

export const TEMPLATES: NotificationTemplate[] = [
  {
    id: "tpl_critical_created",
    name: "Critical ticket created",
    event: "ticket_created",
    role: "technician",
    subject: "🔴 [{{ticket_id}}] Critical · {{title}}",
    body:
      "A critical ticket was just created and routed to your group.\n\n" +
      "**Ticket:** {{ticket_id}} — {{title}}\n" +
      "**Requester:** {{requester}}\n" +
      "**Group:** {{group}}\n" +
      "**SLA due:** {{sla_due_at}}\n\n" +
      "Open the ticket to acknowledge within 5 minutes.",
    language: "en",
    updatedAt: hours(48),
  },
  {
    id: "tpl_sla_warning",
    name: "SLA warning — 30 min",
    event: "sla_warning",
    role: "technician",
    subject: "⏰ {{ticket_id}} — SLA due in 30 minutes",
    body:
      "Heads up: ticket **{{ticket_id}}** ({{priority}}) is due at {{sla_due_at}}.\n\n" +
      "Update the requester or escalate before the SLA timer expires.",
    language: "en",
    updatedAt: hours(120),
  },
  {
    id: "tpl_sla_breach",
    name: "SLA breach escalation",
    event: "sla_breach",
    role: "supervisor",
    subject: "🚨 SLA breached — {{ticket_id}}",
    body:
      "The resolution SLA on {{ticket_id}} was exceeded.\n\n" +
      "**Assignee:** {{assignee}}  \n**Overdue by:** {{overdue_minutes}} min\n\n" +
      "Reassign or escalate to L2.",
    language: "en",
    updatedAt: hours(72),
  },
  {
    id: "tpl_solved_requester",
    name: "Ticket solved — confirmation",
    event: "status_changed",
    role: "requester",
    subject: "Your ticket {{ticket_id}} has been solved",
    body:
      "Hi {{requester_first_name}},\n\n" +
      "{{assignee}} marked your ticket as **Solved**:\n\n" +
      "> {{title}}\n\n" +
      "If the issue is resolved, no action needed — it will close automatically in 48 hours.\n" +
      "Otherwise, reply to this email to reopen it.",
    language: "en",
    updatedAt: hours(240),
  },
  {
    id: "tpl_approval_request",
    name: "Approval requested",
    event: "approval_requested",
    role: "supervisor",
    subject: "Approval requested — {{ticket_id}} ({{amount}})",
    body:
      "{{requester}} is requesting approval for ticket **{{ticket_id}}**.\n\n" +
      "**Item:** {{title}}\n**Estimated cost:** {{amount}}\n\nApprove or reject in GLPI.",
    language: "en",
    updatedAt: hours(500),
  },
];

export const PREFERENCES: UserPreferences = {
  channels: { in_app: true, email: true, sms: false },
  quietHours: { enabled: true, from: "20:00", to: "07:30" },
  frequency: "instant",
  mutedTickets: ["INC-10018"],
  mutedCategories: [],
  language: "en",
  timezone: "Europe/Paris",
};

export const DELIVERY_LOGS: DeliveryLog[] = [
  {
    id: "dl1",
    notificationId: "n1",
    ticketId: "INC-10031",
    recipient: "priya.iyer@acme.eu",
    channel: "email",
    template: "tpl_sla_breach",
    status: "delivered",
    attempts: 1,
    sentAt: minutes(3),
    deliveredAt: minutes(2),
  },
  {
    id: "dl2",
    notificationId: "n1",
    ticketId: "INC-10031",
    recipient: "+33 6 12 34 56 78",
    channel: "sms",
    template: "tpl_sla_breach",
    status: "failed",
    attempts: 2,
    errorReason: "SMS gateway timeout (provider returned 504 after 30s)",
    sentAt: minutes(3),
  },
  {
    id: "dl3",
    notificationId: "n2",
    ticketId: "INC-10042",
    recipient: "marcus.okonkwo@acme.eu",
    channel: "in_app",
    template: "tpl_followup",
    status: "opened",
    attempts: 1,
    sentAt: minutes(12),
    deliveredAt: minutes(12),
    openedAt: minutes(8),
  },
  {
    id: "dl4",
    notificationId: "n3",
    ticketId: "INC-10042",
    recipient: "marcus.okonkwo@acme.eu",
    channel: "email",
    template: "tpl_sla_warning",
    status: "delivered",
    attempts: 1,
    sentAt: minutes(20),
    deliveredAt: minutes(19),
  },
  {
    id: "dl5",
    notificationId: "n5",
    ticketId: "REQ-20188",
    recipient: "priya.iyer@acme.eu",
    channel: "email",
    template: "tpl_approval_request",
    status: "failed",
    attempts: 3,
    errorReason: "Recipient mailbox full (552 5.2.2)",
    sentAt: minutes(36),
  },
  {
    id: "dl6",
    notificationId: "n6",
    ticketId: "INC-10027",
    recipient: "lin.wei@acme.eu",
    channel: "email",
    template: "tpl_solved_requester",
    status: "opened",
    attempts: 1,
    sentAt: hours(1),
    deliveredAt: hours(1),
    openedAt: minutes(40),
  },
  {
    id: "dl7",
    notificationId: "n7",
    ticketId: "INC-10039",
    recipient: "marcus.okonkwo@acme.eu",
    channel: "in_app",
    template: "tpl_priority_changed",
    status: "sent",
    attempts: 1,
    sentAt: hours(2),
  },
  {
    id: "dl8",
    notificationId: "n9",
    ticketId: "INC-10042",
    recipient: "service-desk@acme.eu",
    channel: "email",
    template: "tpl_critical_created",
    status: "queued",
    attempts: 0,
    sentAt: hours(6),
  },
];

export const EVENT_LABEL: Record<EventType, string> = {
  ticket_created: "Ticket created",
  ticket_assigned: "Ticket assigned",
  ticket_reassigned: "Ticket reassigned",
  status_changed: "Status changed",
  new_followup: "New follow-up",
  sla_warning: "SLA warning",
  sla_breach: "SLA breach",
  approval_requested: "Approval requested",
  approval_approved: "Approval approved",
  approval_rejected: "Approval rejected",
  priority_changed: "Priority changed",
  ticket_reopened: "Ticket reopened",
};

export const PRIORITY_LABEL: Record<Priority, string> = {
  low: "Low",
  medium: "Medium",
  high: "High",
  critical: "Critical",
};

export const STATUS_LABEL: Record<TicketStatus, string> = {
  new: "New",
  in_progress: "In progress",
  pending: "Pending",
  solved: "Solved",
  closed: "Closed",
};
