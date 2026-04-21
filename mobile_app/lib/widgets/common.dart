import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/theme/app_colors.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class PriorityPill extends StatelessWidget {
  const PriorityPill({super.key, required this.priority});
  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (priority) {
      Priority.low => (AppColors.successSoft, AppColors.success, 'Low'),
      Priority.medium => (AppColors.infoSoft, AppColors.info, 'Medium'),
      Priority.high => (AppColors.warningSoft, AppColors.warning, 'High'),
      Priority.critical => (AppColors.destructiveSoft, AppColors.destructive, 'Critical'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TicketStatus.open => 'New',
      TicketStatus.inProgress => 'In Progress',
      TicketStatus.pending => 'Pending',
      TicketStatus.solved => 'Solved',
      TicketStatus.closed => 'Closed',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.accentForeground)),
    );
  }
}

IconData channelIcon(Channel channel) {
  return switch (channel) {
    Channel.inApp => Icons.phone_iphone_outlined,
    Channel.email => Icons.mail_outline,
    Channel.sms => Icons.sms_outlined,
  };
}

String channelLabel(Channel channel) {
  return switch (channel) {
    Channel.inApp => 'In-app',
    Channel.email => 'Email',
    Channel.sms => 'SMS',
  };
}
