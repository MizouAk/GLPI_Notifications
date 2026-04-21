import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/common.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key, required this.notifications, required this.role});
  final List<AppNotification> notifications;
  final AppRole role;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String query = '';
  final Set<String> selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final items = widget.notifications
        .where((n) => !n.archived && n.role == widget.role)
        .where((n) =>
            query.isEmpty ||
            '${n.title} ${n.body} ${n.ticketId}'.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final unread = items.where((e) => !e.read).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Notification center', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Inbox', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('$unread unread', style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Filter by ticket ID, keyword...',
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (selected.isNotEmpty)
          SurfaceCard(
            child: Row(
              children: [
                Text('${selected.length} selected', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    for (final n in items.where((e) => selected.contains(e.id))) {
                      n.read = true;
                    }
                    setState(selected.clear);
                  },
                  child: const Text('Mark read'),
                ),
                TextButton(
                  onPressed: () {
                    for (final n in items.where((e) => selected.contains(e.id))) {
                      n.archived = true;
                    }
                    setState(selected.clear);
                  },
                  child: const Text('Archive'),
                ),
              ],
            ),
          ),
        if (selected.isNotEmpty) const SizedBox(height: 10),
        ...items.map((n) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selected.contains(n.id),
                    onChanged: (_) {
                      setState(() {
                        if (selected.contains(n.id)) {
                          selected.remove(n.id);
                        } else {
                          selected.add(n.id);
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => n.read = true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: n.read ? FontWeight.w500 : FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (!n.read)
                                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            style: const TextStyle(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              PriorityPill(priority: n.priority),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: AppColors.surfaceMuted,
                                ),
                                child: Text(
                                  '${n.ticketId} • ${channelLabel(n.channel)} • ${n.timeAgo}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
