import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/common.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key, required this.logs});
  final List<DeliveryLog> logs;

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.logs
        .where((log) => query.isEmpty || '${log.recipient} ${log.ticketId}'.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final failed = filtered.where((e) => e.status == DeliveryStatus.failed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Reliability · Observability', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('Audit & Delivery', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (failed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.destructive),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${failed.length} failed deliveries waiting for retry')),
                  TextButton(onPressed: () {}, child: const Text('Retry all')),
                ],
              ),
            ),
          ),
        SurfaceCard(
          child: TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              hintText: 'Search by recipient, ticket, template...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...filtered.map((log) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(channelIcon(log.channel)),
                title: Text('${log.ticketId} • ${log.recipient}'),
                subtitle: Text('${log.template} • ${log.sentAt}'),
                trailing: Text(
                  log.status.name,
                  style: TextStyle(
                    color: log.status == DeliveryStatus.failed ? AppColors.destructive : AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showDetails(context, log),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showDetails(BuildContext context, DeliveryLog log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Ticket: ${log.ticketId}'),
              Text('Recipient: ${log.recipient}'),
              Text('Channel: ${channelLabel(log.channel)}'),
              Text('Status: ${log.status.name}'),
              Text('Attempts: ${log.attempts}/3'),
              if (log.errorReason != null) Text('Error: ${log.errorReason}'),
              const SizedBox(height: 10),
              if (log.status == DeliveryStatus.failed)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        log.status = DeliveryStatus.delivered;
                        log.attempts += 1;
                        log.errorReason = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Retry now'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
