import 'package:flutter/material.dart';
import 'package:mobile_app/helpdesk/data/mock_helpdesk_data.dart';
import 'package:mobile_app/helpdesk/design_system/app_tokens.dart';
import 'package:mobile_app/helpdesk/models/helpdesk_models.dart';
import 'package:mobile_app/helpdesk/services/glpi_api_client.dart';
import 'package:mobile_app/helpdesk/services/glpi_auth_storage.dart';
import 'package:mobile_app/helpdesk/widgets/ui_components.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key, required this.onThemeChanged});
  final ValueChanged<bool> onThemeChanged;

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  _AppShellScreenState()
      : _serverController = TextEditingController(text: 'http://10.0.2.2:8080'),
        _usernameController = TextEditingController(),
        _passwordController = TextEditingController();

  int _index = 0;
  bool _authenticated = false;
  AppRole _role = AppRole.user;
  bool _unreadOnly = false;
  final bool _showLoading = false;
  int _selectedTicketFilter = 0;
  bool _authenticating = false;
  String? _authError;
  String _displayUser = 'Guest';
  String? _accessToken;
  List<Ticket> _liveTickets = tickets;
  final GlpiAuthStorage _authStorage = GlpiAuthStorage();
  final TextEditingController _serverController;
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;

  List<Ticket> get _currentTickets => _liveTickets;
  bool get _canModerateTickets => _role == AppRole.admin || _role == AppRole.technicien;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await _authStorage.readSession();
    if (!mounted || session == null) {
      return;
    }

    setState(() {
      _serverController.text = session.baseUrl;
      _usernameController.text = session.username;
      _authError = 'Session restored. Please enter your password to continue.';
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              Text('Sign in to manage GLPI data directly.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              TextField(controller: _serverController, decoration: const InputDecoration(labelText: 'Backend Base URL')),
              const SizedBox(height: 12),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 12),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 16),
              HdButton.primary(
                label: 'Sign in',
                loading: _authenticating,
                onPressed: _authenticating ? null : _login,
              ),
              if (_authError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _authError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.danger),
                ),
              ],
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
    final open = _currentTickets.where((e) => e.status != TicketStatus.closed).length;
    final closed = _currentTickets.where((e) => e.status == TicketStatus.closed).length;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.padding),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${_displayUser.toUpperCase()}', style: Theme.of(context).textTheme.titleLarge),
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
                  _metricCard(context, 'Total tickets', '${_currentTickets.length}', Icons.confirmation_num_outlined),
                  _metricCard(context, 'Open tickets', '$open', Icons.inbox_outlined),
                  _metricCard(context, 'Closed tickets', '$closed', Icons.check_circle_outline),
                ],
              ),
        const SizedBox(height: AppTokens.sectionSpacing),
        Text('Recent activity', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (_currentTickets.isEmpty)
          HdCard(child: Text('No items to show.', style: Theme.of(context).textTheme.bodySmall))
        else
          ..._currentTickets.take(3).map((t) => Padding(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final valueColor = isDark ? AppPalette.darkText : AppPalette.textPrimary;
    final labelColor = isDark ? AppPalette.darkText2 : AppPalette.textSecondary;

    return HdCard(
      radius: AppTokens.radiusFeatured,
      padding: EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusFeatured),
          border: Border.all(color: AppPalette.border.withValues(alpha: isDark ? 0.4 : 0.85)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppPalette.primary.withValues(alpha: isDark ? 0.16 : 0.12),
              surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppPalette.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: AppPalette.primary),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: valueColor)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 1,
                      minHeight: 4,
                      backgroundColor: AppPalette.border.withValues(alpha: 0.6),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketFilterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? AppPalette.primary.withValues(alpha: 0.12) : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppPalette.primary : AppPalette.border),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppPalette.primary : AppPalette.textSecondary,
                ),
          ),
        ),
      ),
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
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              const labels = ['Open', 'Closed', 'Urgent', 'Assigned to me'];
              return _ticketFilterChip(
                context,
                label: labels[index],
                selected: _selectedTicketFilter == index,
                onTap: () => setState(() => _selectedTicketFilter = index),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (_showLoading) ...[
          const LoadingSkeleton(height: 96, radius: 14),
          const SizedBox(height: 10),
          const LoadingSkeleton(height: 112, radius: 14),
        ] else ...[
          if (_currentTickets.isEmpty)
            HdCard(child: Text('No tickets/assets found.', style: Theme.of(context).textTheme.bodySmall)),
          ..._currentTickets.map((ticket) => Padding(
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
                Expanded(
                  child: HdButton.primary(
                    label: 'Add Comment',
                    onPressed: _canModerateTickets ? () => _addCommentToTicket(context, ticket) : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HdButton.secondary(
                    label: 'Change Status',
                    onPressed: _canModerateTickets ? () => _changeTicketStatus(context, ticket) : null,
                  ),
                ),
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
    bool submitting = false;

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
              loading: submitting,
              onPressed: (!valid || submitting || _accessToken == null)
                  ? null
                  : () async {
                      setLocal(() => submitting = true);
                      try {
                        final api = GlpiApiClient(baseUrl: _serverController.text.trim());
                        await api.createTicket(
                          accessToken: _accessToken!,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          priority: priority,
                        );
                        await _refreshTickets();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submitted')));
                        setState(() => _index = 1);
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                        );
                      } finally {
                        if (context.mounted) {
                          setLocal(() => submitting = false);
                        }
                      }
                    },
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayUser),
                    Text(_serverController.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Chip(label: Text(_role.name)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _profileTile(context, 'Role', _role.name, onTap: null),
        _profileTile(context, 'Dark mode', 'Toggle theme', onTap: () => widget.onThemeChanged(Theme.of(context).brightness == Brightness.light)),
        const SizedBox(height: 24),
        HdButton.destructive(
          label: 'Logout',
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _profileTile(BuildContext context, String title, String subtitle, {VoidCallback? onTap}) {
    final tileContent = Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), Text(subtitle, style: Theme.of(context).textTheme.bodySmall)])),
          Icon(onTap == null ? Icons.lock_outline : Icons.chevron_right_rounded),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: onTap == null ? tileContent : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: tileContent),
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    setState(() {
      _authenticated = false;
      _index = 0;
      _accessToken = null;
      _liveTickets = tickets;
      _displayUser = 'Guest';
      _role = AppRole.user;
      _authError = null;
      _passwordController.clear();
    });
    try {
      await _authStorage.clearSession();
    } catch (_) {
      // Even if secure storage fails, force local logout state.
    }
  }

  Color _priorityColor(TicketPriority priority) => switch (priority) {
        TicketPriority.low => AppPalette.border,
        TicketPriority.medium => AppPalette.warning,
        TicketPriority.high => AppPalette.primary,
        TicketPriority.urgent => AppPalette.danger,
      };

  Future<void> _login() async {
    final baseUrl = _serverController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if ([baseUrl, username, password].any((v) => v.isEmpty)) {
      setState(() => _authError = 'Please fill all fields.');
      return;
    }

    setState(() {
      _authenticating = true;
      _authError = null;
    });

    try {
      final client = GlpiApiClient(baseUrl: baseUrl);
      final auth = await client.login(
        username: username,
        password: password,
      );
      await _authenticateWithToken(
        token: auth.accessToken,
        username: auth.username,
        role: auth.role,
        saveSession: true,
      );
      _passwordController.clear();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  Future<void> _authenticateWithToken({
    required String token,
    required String username,
    required AppRole role,
    required bool saveSession,
    bool showFailureSnackBar = true,
  }) async {
    final client = GlpiApiClient(baseUrl: _serverController.text.trim());
    final liveTickets = await client.fetchTickets(token);
    if (!mounted) return;

    setState(() {
      _accessToken = token;
      _liveTickets = liveTickets;
      _authenticated = true;
      _displayUser = username;
      _role = role;
      _authError = null;
    });

    if (saveSession) {
      await _authStorage.saveSession(
        GlpiSessionData(
          baseUrl: _serverController.text.trim(),
          username: username,
        ),
      );
    }

    if (showFailureSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to GLPI (${liveTickets.length} items loaded)')),
      );
    }
  }

  Future<void> _refreshTickets() async {
    if (_accessToken == null) return;
    final client = GlpiApiClient(baseUrl: _serverController.text.trim());
    final refreshed = await client.fetchTickets(_accessToken!);
    if (!mounted) return;
    setState(() => _liveTickets = refreshed);
  }

  Future<void> _addCommentToTicket(BuildContext context, Ticket ticket) async {
    if (_accessToken == null) return;
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Comment'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (content == null || content.isEmpty) return;
    try {
      final api = GlpiApiClient(baseUrl: _serverController.text.trim());
      await api.addComment(
        accessToken: _accessToken!,
        ticketId: ticket.id,
        content: content,
      );
      await _refreshTickets();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment added')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _changeTicketStatus(BuildContext context, Ticket ticket) async {
    if (_accessToken == null) return;
    final selected = await showModalBottomSheet<TicketStatus>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Open'), onTap: () => Navigator.of(ctx).pop(TicketStatus.open)),
            ListTile(title: const Text('In Progress'), onTap: () => Navigator.of(ctx).pop(TicketStatus.inProgress)),
            ListTile(title: const Text('Closed'), onTap: () => Navigator.of(ctx).pop(TicketStatus.closed)),
          ],
        ),
      ),
    );

    if (selected == null) return;
    try {
      final api = GlpiApiClient(baseUrl: _serverController.text.trim());
      await api.updateTicketStatus(
        accessToken: _accessToken!,
        ticketId: ticket.id,
        status: selected,
      );
      await _refreshTickets();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}
