import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/common.dart';

class SlaScreen extends StatelessWidget {
  const SlaScreen({super.key, required this.tickets, required this.role});
  final List<SlaTicket> tickets;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final overdue = tickets.where((e) => e.overdue).length;
    final next1h = tickets.where((e) => !e.overdue && e.slaLabel.contains('min')).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('SLA Operations', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('SLA Dashboard', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _kpi('Overdue', '$overdue', AppColors.destructiveSoft, AppColors.destructive)),
            const SizedBox(width: 8),
            Expanded(child: _kpi('Due in 1h', '$next1h', AppColors.warningSoft, AppColors.warning)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _kpi('Due in 4h', '2', AppColors.infoSoft, AppColors.info)),
            const SizedBox(width: 8),
            Expanded(child: _kpi('Due in 24h', '4', AppColors.surfaceMuted, AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Tickets at risk', style: TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (role == AppRole.supervisor)
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Notify all'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ...tickets.map((t) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    t.overdue ? Icons.warning_amber_rounded : Icons.alarm,
                    color: t.overdue ? AppColors.destructive : AppColors.warning,
                  ),
                  title: Text('${t.id} - ${t.title}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Assigned to ${t.assignee} • ${t.group}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.slaLabel,
                        style: TextStyle(
                          color: t.overdue ? AppColors.destructive : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      PriorityPill(priority: t.priority),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kpi(String title, String value, Color bg, Color fg) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, color: fg, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Container(height: 4, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99))),
        ],
      ),
    );
  }
}
