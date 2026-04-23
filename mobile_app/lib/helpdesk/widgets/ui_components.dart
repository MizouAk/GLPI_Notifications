import 'package:flutter/material.dart';
import 'package:mobile_app/helpdesk/design_system/app_tokens.dart';
import 'package:mobile_app/helpdesk/models/helpdesk_models.dart';

class HdCard extends StatelessWidget {
  const HdCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = AppTokens.radiusCard,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HdButton extends StatelessWidget {
  const HdButton.primary({super.key, required this.label, this.onPressed, this.loading = false})
      : destructive = false,
        ghost = false;
  const HdButton.secondary({super.key, required this.label, this.onPressed, this.loading = false})
      : destructive = false,
        ghost = true;
  const HdButton.destructive({super.key, required this.label, this.onPressed, this.loading = false})
      : destructive = true,
        ghost = false;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool destructive;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final style = ghost
        ? OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
        : FilledButton.styleFrom(
            backgroundColor: destructive ? AppPalette.danger : null,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
    final child = loading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label);
    return ghost ? OutlinedButton(onPressed: loading ? null : onPressed, style: style, child: child) : FilledButton(onPressed: loading ? null : onPressed, style: style, child: child);
  }
}

class TicketBadge extends StatelessWidget {
  const TicketBadge.status(this.status, {super.key}) : priority = null;
  const TicketBadge.priority(this.priority, {super.key}) : status = null;
  final TicketStatus? status;
  final TicketPriority? priority;

  @override
  Widget build(BuildContext context) {
    Color bg = AppPalette.surfaceAlt;
    Color fg = Theme.of(context).textTheme.bodySmall?.color ?? AppPalette.textSecondary;
    String label = '';
    if (status != null) {
      switch (status!) {
        case TicketStatus.open:
          bg = AppPalette.primary.withValues(alpha: 0.12);
          fg = AppPalette.primary;
          label = 'Open';
        case TicketStatus.inProgress:
          bg = AppPalette.warning.withValues(alpha: 0.14);
          fg = AppPalette.warning;
          label = 'In Progress';
        case TicketStatus.closed:
          bg = AppPalette.success.withValues(alpha: 0.14);
          fg = AppPalette.success;
          label = 'Closed';
      }
    } else {
      switch (priority!) {
        case TicketPriority.low:
          bg = AppPalette.surfaceAlt;
          fg = AppPalette.textSecondary;
          label = 'Low';
        case TicketPriority.medium:
          bg = AppPalette.warning.withValues(alpha: 0.14);
          fg = AppPalette.warning;
          label = 'Medium';
        case TicketPriority.high:
          bg = AppPalette.primary.withValues(alpha: 0.12);
          fg = AppPalette.primary;
          label = 'High';
        case TicketPriority.urgent:
          bg = AppPalette.danger.withValues(alpha: 0.12);
          fg = AppPalette.danger;
          label = 'Urgent';
      }
    }
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key, this.height = 16, this.width = double.infinity, this.radius = 10});
  final double height;
  final double width;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark ? AppPalette.darkSurfaceAlt : AppPalette.surfaceAlt;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child});
  final Widget child;
  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.98, upperBound: 1)..value = 1;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapCancel: () => _controller.forward(),
      onTapUp: (_) => _controller.forward(),
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
