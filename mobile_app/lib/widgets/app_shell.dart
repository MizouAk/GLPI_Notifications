import 'package:flutter/material.dart';
import 'package:mobile_app/data/mock_data.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/screens/audit_screen.dart';
import 'package:mobile_app/screens/inbox_screen.dart';
import 'package:mobile_app/screens/preferences_screen.dart';
import 'package:mobile_app/screens/rules_screen.dart';
import 'package:mobile_app/screens/sla_screen.dart';
import 'package:mobile_app/screens/templates_screen.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/common.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  AppRole role = AppRole.technician;

  static const pages = <String>[
    'Inbox',
    'SLA Dashboard',
    'Notification Rules',
    'Templates',
    'My Preferences',
    'Audit & Delivery',
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      InboxScreen(notifications: mockNotifications, role: role),
      SlaScreen(tickets: mockSlaTickets, role: role),
      RulesScreen(rules: mockRules),
      TemplatesScreen(templates: mockTemplates),
      const PreferencesScreen(),
      AuditScreen(logs: mockLogs),
    ];

    final roleNotifications = mockNotifications.where((n) => n.role == role && !n.archived).toList();
    final unread = roleNotifications.where((n) => !n.read).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(pages[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          PopupMenuButton<AppRole>(
            initialValue: role,
            onSelected: (value) => setState(() => role = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: AppRole.requester, child: Text('Requester')),
              PopupMenuItem(value: AppRole.technician, child: Text('Technician')),
              PopupMenuItem(value: AppRole.supervisor, child: Text('Supervisor')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.person_outline),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => _openBellMenu(context, roleNotifications),
              ),
              if (unread > 0)
                const Positioned(
                  right: 10,
                  top: 8,
                  child: CircleAvatar(radius: 4, backgroundColor: AppColors.destructive),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(child: screens[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'SLA'),
          NavigationDestination(icon: Icon(Icons.rule_folder_outlined), label: 'Rules'),
          NavigationDestination(icon: Icon(Icons.article_outlined), label: 'Templates'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Prefs'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Audit'),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.sidebar,
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text('GLPI Notify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text('Console', style: TextStyle(color: Color(0xFFAEC0E8))),
              ),
              ...List.generate(pages.length, (i) {
                return ListTile(
                  selected: i == index,
                  selectedTileColor: AppColors.sidebarAccent,
                  title: Text(pages[i], style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() => index = i);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _openBellMenu(BuildContext context, List<AppNotification> notifications) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (notifications.isEmpty)
                const SurfaceCard(child: Text('You are all caught up.'))
              else
                ...notifications.take(5).map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(channelIcon(n.channel)),
                        title: Text(n.title),
                        subtitle: Text('${n.ticketId} • ${n.timeAgo}'),
                        trailing: !n.read ? const Icon(Icons.circle, size: 8, color: AppColors.primary) : null,
                        onTap: () {
                          setState(() => n.read = true);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
