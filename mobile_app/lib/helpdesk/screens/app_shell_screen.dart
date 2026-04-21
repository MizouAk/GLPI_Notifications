import 'package:flutter/material.dart';
import 'package:mobile_app/helpdesk/data/mock_helpdesk_data.dart';
import 'package:mobile_app/helpdesk/design_system/app_tokens.dart';
import 'package:mobile_app/helpdesk/models/helpdesk_models.dart';
import 'package:mobile_app/helpdesk/widgets/ui_components.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _index = 0;
  bool _authenticated = false;
  AppRole _role = AppRole.agent;
  bool _unreadOnly = false;
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) return _buildLogin(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Scaffold(
        key: ValueKey(_index),
        body: SafeArea(child: _buildPage(context)),
        bottomNavigationBar: NavigationBar(
          height: AppTokens.bottomNavHeight,
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.confirmation_num_outlined), label: 'Tickets'),
            NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Create'),
            NavigationDestination(icon: Icon(Icons.notifications_none_rounded), label: 'Alerts'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppPalette.primary, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Sign in to manage tickets and updates.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              HdButton.primary(
                label: 'Sign in',
                onPressed: () {
                  setState(() => _authenticated = true);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in successfully')));
                },
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () {}, child: const Text('Use token login')),
              TextButton(onPressed: () {}, child: const Text('Forgot password?')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return switch (_index) {
      0 => _buildDashboard(context),
      1 => _buildTickets(context),
      2 => _buildCreateTicket(context),
      3 => _buildNotifications(context),
      _ => _buildProfile(context),
    };
  }

  Widget _buildDashboard(BuildContext context) {
    final open = tickets.where((e) => e.status != TicketStatus.closed).length;
    final closed = tickets.where((e) => e.status == TicketStatus.closed).length;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.padding),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${_role.name.toUpperCase()}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text('Helpdesk overview', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            Chip(label: Text(_role.name)),
            const SizedBox(width: 8),
            const Icon(Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: 16),
        _showLoading
            ? const Column(children: [LoadingSkeleton(height: 110), SizedBox(height: 12), LoadingSkeleton(height: 110)])
            : GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.45,
                children: [
                  _metricCard(context, 'Total tickets', '${tickets.length}', Icons.confirmation_num_outlined),
                  _metricCard(context, 'Open tickets', '$open', Icons.inbox_outlined),
                  _metricCard(context, 'Closed tickets', '$closed', Icons.check_circle_outline),
                ],
              ),
        const SizedBox(height: AppTokens.sectionSpacing),
        Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...tickets.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HdCard(
                child: SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18, child: Icon(Icons.timeline, size: 18)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${t.id} · ${t.title}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                      Text(t.date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _metricCard(BuildContext context, String title, String value, IconData icon) {
    return HdCard(
      radius: AppTokens.radiusFeatured,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppPalette.primary),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  Widget _buildTickets(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.padding),
      children: [
        const SizedBox(
          height: 44,
          child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search tickets')),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              Padding(padding: EdgeInsets.only(right: 8), child: Chip(label: Text('Open'))),
              Padding(padding: EdgeInsets.only(right: 8), child: Chip(label: Text('Closed'))),
              Padding(padding: EdgeInsets.only(right: 8), child: Chip(label: Text('Urgent'))),
              Chip(label: Text('Assigned to me')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_showLoading) ...[
          const LoadingSkeleton(height: 96, radius: 14),
          const SizedBox(height: 10),
          const LoadingSkeleton(height: 112, radius: 14),
        ] else ...[
          ...tickets.map((ticket) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TapScale(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showTicketDetails(context, ticket),
                    child: Container(
                      height: ticket.description.length > 60 ? 112 : 96,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(width: 4, decoration: BoxDecoration(color: _priorityColor(ticket.priority), borderRadius: BorderRadius.circular(12))),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(ticket.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
                                const SizedBox(height: 6),
                                Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                                const Spacer(),
                                Row(children: [
                                  Text(ticket.date, style: Theme.of(context).textTheme.bodySmall),
                                  const Spacer(),
                                  TicketBadge.status(ticket.status),
                                  const SizedBox(width: 6),
                                  TicketBadge.priority(ticket.priority),
                                ]),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ]
      ],
    );
  }

  void _showTicketDetails(BuildContext context, Ticket ticket) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.padding),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(ticket.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Row(children: [Text(ticket.id), const SizedBox(width: 8), TicketBadge.status(ticket.status), const SizedBox(width: 8), TicketBadge.priority(ticket.priority)]),
                    const SizedBox(height: 16),
                    HdCard(child: Text(ticket.description)),
                    const SizedBox(height: 12),
                    HdCard(
                      child: Row(children: [
                        const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Assigned to ${ticket.assignedUser}')),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(width: 2, height: 180, color: AppPalette.border),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: ticket.comments
                              .map((comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: HdCard(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('${comment.author} · ${comment.time}', style: Theme.of(context).textTheme.bodySmall),
                                        const SizedBox(height: 4),
                                        Text(comment.message),
                                      ]),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              Row(children: [
                Expanded(child: HdButton.primary(label: 'Add Comment', onPressed: () {})),
                const SizedBox(width: 10),
                Expanded(child: HdButton.secondary(label: 'Change Status', onPressed: _role == AppRole.user ? null : () {})),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTicket(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TicketPriority priority = TicketPriority.medium;
    bool valid = false;

    return StatefulBuilder(
      builder: (context, setLocal) {
        void updateValid() => setLocal(() => valid = titleController.text.trim().isNotEmpty && descriptionController.text.trim().isNotEmpty);
        return ListView(
          padding: const EdgeInsets.all(AppTokens.padding),
          children: [
            Text('Create Ticket', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(controller: titleController, onChanged: (_) => updateValid(), decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 140),
              child: TextField(
                minLines: 6,
                maxLines: 7,
                controller: descriptionController,
                onChanged: (_) => updateValid(),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: TicketPriority.values
                  .map((value) => ChoiceChip(
                        label: Text(value.name),
                        selected: priority == value,
                        onSelected: (_) => setLocal(() => priority = value),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            HdButton.primary(
              label: 'Submit ticket',
              onPressed: valid
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submitted')));
                      setState(() => _index = 1);
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotifications(BuildContext context) {
    final data = _unreadOnly
        ? (
            alertsToday.where((a) => a.unread).toList(),
            alertsYesterday.where((a) => a.unread).toList(),
          )
        : (alertsToday, alertsYesterday);
    return ListView(
      padding: const EdgeInsets.all(AppTokens.padding),
      children: [
        Row(
          children: [
            FilterChip(label: const Text('Unread only'), selected: _unreadOnly, onSelected: (_) => setState(() => _unreadOnly = !_unreadOnly)),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Mark all read')),
          ],
        ),
        const SizedBox(height: 12),
        _alertSection(context, 'Today', data.$1),
        const SizedBox(height: 18),
        _alertSection(context, 'Yesterday', data.$2),
      ],
    );
  }

  Widget _alertSection(BuildContext context, String title, List alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_showLoading)
          const LoadingSkeleton(height: 72, radius: 14)
        else if (alerts.isEmpty)
          HdCard(child: Text('No notifications', style: Theme.of(context).textTheme.bodySmall))
        else
          ...alerts.map<Widget>(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HdCard(
                child: SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18, child: Icon(Icons.notifications_active_outlined, size: 16)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(alert.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(alert.time), if (alert.unread) const CircleAvatar(radius: 4, backgroundColor: AppPalette.primary)]),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.padding),
      children: [
        HdCard(
          radius: AppTokens.radiusFeatured,
          child: Row(
            children: [
              const CircleAvatar(radius: 28, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Amine Bennani'), Text('amine@company.com')])),
              Chip(label: Text(_role.name)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _profileTile(context, 'Role', _role.name, onTap: _switchRole),
        _profileTile(context, 'Dark mode', 'Toggle theme', onTap: () => widget.onThemeChanged(Theme.of(context).brightness == Brightness.light)),
        _profileTile(context, 'Show loading skeletons', _showLoading ? 'Enabled' : 'Disabled', onTap: () => setState(() => _showLoading = !_showLoading)),
        const SizedBox(height: 24),
        HdButton.destructive(
          label: 'Logout',
          onPressed: () {
            setState(() {
              _authenticated = false;
              _index = 0;
            });
          },
        ),
      ],
    );
  }

  Widget _profileTile(BuildContext context, String title, String subtitle, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  void _switchRole() {
    setState(() {
      _role = switch (_role) {
        AppRole.admin => AppRole.agent,
        AppRole.agent => AppRole.user,
        AppRole.user => AppRole.admin,
      };
    });
  }

  Color _priorityColor(TicketPriority priority) => switch (priority) {
        TicketPriority.low => AppPalette.border,
        TicketPriority.medium => AppPalette.warning,
        TicketPriority.high => AppPalette.primary,
        TicketPriority.urgent => AppPalette.danger,
      };
}
