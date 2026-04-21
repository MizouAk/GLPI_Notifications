import { cn } from "@/lib/utils";
import type { Priority, TicketStatus, EventType, DeliveryStatus, Channel } from "@/data/mock";
import { PRIORITY_LABEL, STATUS_LABEL, EVENT_LABEL } from "@/data/mock";
import {
  AlertTriangle,
  Bell,
  CheckCircle2,
  Clock,
  FileText,
  Flag,
  MessageSquare,
  RefreshCw,
  RotateCcw,
  ShieldCheck,
  ThumbsDown,
  ThumbsUp,
  UserPlus,
  Mail,
  Smartphone,
  MonitorSmartphone,
} from "lucide-react";

export const PriorityBadge = ({ priority }: { priority: Priority }) => {
  const map: Record<Priority, string> = {
    low: "bg-success-soft text-success border-success/20",
    medium: "bg-info-soft text-info border-info/20",
    high: "bg-warning-soft text-warning border-warning/30",
    critical: "bg-destructive-soft text-destructive border-destructive/30",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-md border px-1.5 py-0.5 text-[11px] font-semibold",
        map[priority]
      )}
    >
      <span
        className={cn(
          "h-1.5 w-1.5 rounded-full",
          priority === "low" && "bg-success",
          priority === "medium" && "bg-info",
          priority === "high" && "bg-warning",
          priority === "critical" && "bg-destructive animate-pulse-dot"
        )}
      />
      {PRIORITY_LABEL[priority]}
    </span>
  );
};

export const StatusBadge = ({ status }: { status: TicketStatus }) => {
  const map: Record<TicketStatus, string> = {
    new: "bg-accent text-accent-foreground border-accent",
    in_progress: "bg-info-soft text-info border-info/20",
    pending: "bg-warning-soft text-warning border-warning/20",
    solved: "bg-success-soft text-success border-success/20",
    closed: "bg-muted text-muted-foreground border-border",
  };
  return (
    <span className={cn("inline-flex rounded-md border px-1.5 py-0.5 text-[11px] font-medium", map[status])}>
      {STATUS_LABEL[status]}
    </span>
  );
};

const EVENT_ICON: Record<EventType, typeof Bell> = {
  ticket_created: FileText,
  ticket_assigned: UserPlus,
  ticket_reassigned: UserPlus,
  status_changed: RefreshCw,
  new_followup: MessageSquare,
  sla_warning: Clock,
  sla_breach: AlertTriangle,
  approval_requested: ShieldCheck,
  approval_approved: ThumbsUp,
  approval_rejected: ThumbsDown,
  priority_changed: Flag,
  ticket_reopened: RotateCcw,
};

export const EventIcon = ({ event, className }: { event: EventType; className?: string }) => {
  const Icon = EVENT_ICON[event];
  const tone: Partial<Record<EventType, string>> = {
    sla_warning: "text-warning bg-warning-soft",
    sla_breach: "text-destructive bg-destructive-soft",
    approval_approved: "text-success bg-success-soft",
    approval_rejected: "text-destructive bg-destructive-soft",
    ticket_created: "text-info bg-info-soft",
    new_followup: "text-info bg-info-soft",
    status_changed: "text-accent-foreground bg-accent",
    ticket_reopened: "text-warning bg-warning-soft",
  };
  return (
    <span
      className={cn(
        "inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-md",
        tone[event] ?? "text-accent-foreground bg-accent",
        className
      )}
      aria-label={EVENT_LABEL[event]}
    >
      <Icon className="h-4 w-4" />
    </span>
  );
};

export const ChannelIcon = ({ channel, className }: { channel: Channel; className?: string }) => {
  const Icon = channel === "email" ? Mail : channel === "sms" ? Smartphone : MonitorSmartphone;
  return <Icon className={cn("h-3.5 w-3.5", className)} aria-label={channel} />;
};

export const DeliveryBadge = ({ status }: { status: DeliveryStatus }) => {
  const map: Record<DeliveryStatus, { c: string; label: string; Icon: typeof Bell }> = {
    sent: { c: "bg-muted text-muted-foreground border-border", label: "Sent", Icon: RefreshCw },
    delivered: { c: "bg-success-soft text-success border-success/20", label: "Delivered", Icon: CheckCircle2 },
    opened: { c: "bg-info-soft text-info border-info/20", label: "Opened", Icon: CheckCircle2 },
    failed: { c: "bg-destructive-soft text-destructive border-destructive/20", label: "Failed", Icon: AlertTriangle },
    queued: { c: "bg-warning-soft text-warning border-warning/20", label: "Queued", Icon: Clock },
  };
  const { c, label, Icon } = map[status];
  return (
    <span className={cn("inline-flex items-center gap-1 rounded-md border px-1.5 py-0.5 text-[11px] font-medium", c)}>
      <Icon className="h-3 w-3" />
      {label}
    </span>
  );
};
