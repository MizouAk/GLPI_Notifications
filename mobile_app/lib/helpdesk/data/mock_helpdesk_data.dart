import 'package:mobile_app/helpdesk/models/helpdesk_models.dart';

const tickets = <Ticket>[
  Ticket(
    id: '#INC-3021',
    title: 'VPN disconnects every 10 minutes',
    description: 'Users in Lyon office report unstable VPN sessions after latest router patch.',
    status: TicketStatus.open,
    priority: TicketPriority.urgent,
    date: 'Today',
    assignedUser: 'Samir Haddad',
    comments: [
      TicketComment(author: 'Samir', time: '09:12', message: 'Investigating router logs now.'),
      TicketComment(author: 'Nora', time: '09:40', message: 'Issue confirmed on 12 devices.'),
    ],
  ),
  Ticket(
    id: '#INC-3016',
    title: 'Laptop enrollment blocked in MDM',
    description: 'Enrollment flow stuck on policy sync step for new hires.',
    status: TicketStatus.inProgress,
    priority: TicketPriority.high,
    date: 'Yesterday',
    assignedUser: 'Lina Zhao',
    comments: [
      TicketComment(author: 'Lina', time: '15:10', message: 'Backend token appears expired.'),
    ],
  ),
  Ticket(
    id: '#INC-2988',
    title: 'Outlook crash on launch',
    description: 'Resolved by clean profile reset and office patch.',
    status: TicketStatus.closed,
    priority: TicketPriority.medium,
    date: 'Apr 18',
    assignedUser: 'Marcus Kent',
    comments: [
      TicketComment(author: 'Marcus', time: '11:22', message: 'User validated fix; ticket closed.'),
    ],
  ),
];

const alertsToday = <AlertItem>[
  AlertItem(
    title: 'New urgent ticket assigned',
    subtitle: '#INC-3021 assigned to Network Team',
    time: '2m',
    unread: true,
  ),
  AlertItem(
    title: 'Status updated to In Progress',
    subtitle: '#INC-3016 was updated by Lina Zhao',
    time: '18m',
    unread: true,
  ),
];

const alertsYesterday = <AlertItem>[
  AlertItem(
    title: 'Ticket closed successfully',
    subtitle: '#INC-2988 has been marked closed',
    time: '1d',
    unread: false,
  ),
];
