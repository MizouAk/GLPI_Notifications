import { useMemo } from "react";
import { useApp } from "@/store/app";
import { TICKETS } from "@/data/mock";
import { PriorityBadge, StatusBadge } from "@/components/notif/Badges";
import { slaCountdown, relTime } from "@/lib/time";
import {
  AlarmClock,
  AlertTriangle,
  ArrowUpRight,
  BellRing,
  Flame,
  Send,
  Timer,
  TrendingUp,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const SLA = () => {
  const role = useApp((s) => s.role);

  const buckets = useMemo(() => {
    const due1h: typeof TICKETS = [];
    const due4h: typeof TICKETS = [];
    const due24h: typeof TICKETS = [];
    const overdue: typeof TICKETS = [];
    TICKETS.forEach((t) => {
      const { mins } = slaCountdown(t.slaDueAt);
      if (mins < 0) overdue.push(t);
      else if (mins <= 60) due1h.push(t);
      else if (mins <= 240) due4h.push(t);
      else if (mins <= 1440) due24h.push(t);
    });
    return { due1h, due4h, due24h, overdue };
  }, []);

  const highOverdue = buckets.overdue.filter((t) => t.priority === "high" || t.priority === "critical");

  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <div className="text-eyebrow">SLA Operations</div>
        <h2 className="mt-1 text-2xl font-semibold tracking-tight">SLA Dashboard</h2>
        <p className="text-sm text-muted-foreground mt-1">
          Real-time view of tickets approaching or breaching their resolution SLA.
        </p>
      </div>

      {/* KPI cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <KpiCard
          tone="destructive"
          icon={<Flame className="h-4 w-4" />}
          label="Overdue"
          value={buckets.overdue.length}
          hint={`${highOverdue.length} high-priority`}
        />
        <KpiCard
          tone="warning"
          icon={<AlarmClock className="h-4 w-4" />}
          label="Due in next 1h"
          value={buckets.due1h.length}
          hint="Notify or escalate"
        />
        <KpiCard
          tone="info"
          icon={<Timer className="h-4 w-4" />}
          label="Due in next 4h"
          value={buckets.due4h.length}
          hint="Plan your queue"
        />
        <KpiCard
          tone="muted"
          icon={<TrendingUp className="h-4 w-4" />}
          label="Due in next 24h"
          value={buckets.due24h.length}
          hint="Healthy backlog"
        />
      </div>

      {/* Two columns: at risk + escalation timeline */}
      <div className="grid lg:grid-cols-3 gap-5">
        <div className="lg:col-span-2 surface-card overflow-hidden">
          <div className="flex items-center justify-between px-4 py-3 border-b border-border">
            <div>
              <h3 className="text-sm font-semibold">Tickets at risk</h3>
              <p className="text-[11px] text-muted-foreground">Sorted by closest SLA deadline first.</p>
            </div>
            {role === "supervisor" && (
              <button
                onClick={() => toast.success("Notified 3 assignees and their managers")}
                className="inline-flex items-center gap-1.5 rounded-md bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground hover:bg-primary-hover focus-ring"
              >
                <BellRing className="h-3.5 w-3.5" /> Notify all assignees
              </button>
            )}
          </div>
          <ul>
            {[...buckets.overdue, ...buckets.due1h, ...buckets.due4h]
              .sort((a, b) => slaCountdown(a.slaDueAt).mins - slaCountdown(b.slaDueAt).mins)
              .slice(0, 6)
              .map((t) => {
                const sla = slaCountdown(t.slaDueAt);
                return (
                  <li key={t.id} className="data-row">
                    <div className="flex items-start gap-3 px-4 py-3">
                      <div
                        className={cn(
                          "mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-md",
                          sla.overdue ? "bg-destructive-soft text-destructive" : "bg-warning-soft text-warning"
                        )}
                      >
                        {sla.overdue ? <AlertTriangle className="h-4 w-4" /> : <AlarmClock className="h-4 w-4" />}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-mono text-[12px] font-semibold text-foreground">{t.id}</span>
                          <PriorityBadge priority={t.priority} />
                          <StatusBadge status={t.status} />
                        </div>
                        <p className="text-sm font-medium mt-0.5 truncate">{t.title}</p>
                        <div className="mt-0.5 text-[11px] text-muted-foreground">
                          Assigned to {t.assignee} · {t.group}
                        </div>
                      </div>
                      <div className="hidden md:flex flex-col items-end shrink-0">
                        <span
                          className={cn(
                            "text-[12px] font-semibold",
                            sla.overdue ? "text-destructive" : "text-warning"
                          )}
                        >
                          {sla.label}
                        </span>
                        <button
                          onClick={() => toast.success(`Notification sent for ${t.id}`)}
                          className="mt-1 inline-flex items-center gap-1 rounded border border-border bg-background px-2 py-1 text-[10px] font-medium hover:bg-muted focus-ring"
                        >
                          <Send className="h-3 w-3" /> Notify now
                        </button>
                      </div>
                    </div>
                  </li>
                );
              })}
          </ul>
        </div>

        {/* Escalation timeline */}
        <div className="surface-card overflow-hidden">
          <div className="px-4 py-3 border-b border-border">
            <h3 className="text-sm font-semibold">Escalation timeline — INC-10031</h3>
            <p className="text-[11px] text-muted-foreground">Critical · Production DB replica lag</p>
          </div>
          <ol className="px-4 py-4 space-y-4 relative">
            <span aria-hidden className="absolute left-[26px] top-5 bottom-5 w-px bg-border" />
            <TimelineStep
              tone="success"
              time="14:02"
              title="Ticket created"
              detail="Auto-routed to IT — Operations by category rule."
            />
            <TimelineStep
              tone="info"
              time="14:04"
              title="Assigned to Priya Iyer"
              detail="Selected as primary on-call for Infrastructure."
            />
            <TimelineStep
              tone="warning"
              time="15:32"
              title="SLA warning sent"
              detail="In-app + email to assignee, 30 min before SLA."
            />
            <TimelineStep
              tone="destructive"
              time="16:02"
              title="SLA breached"
              detail="Escalation rule fired: notified manager + on-call channel."
              active
            />
            <TimelineStep
              tone="muted"
              time="—"
              title="L2 escalation pending"
              detail="If unresolved by 16:30, auto-page L2 infra lead."
            />
          </ol>
        </div>
      </div>
    </div>
  );
};

const KpiCard = ({
  icon,
  label,
  value,
  hint,
  tone,
}: {
  icon: React.ReactNode;
  label: string;
  value: number;
  hint: string;
  tone: "destructive" | "warning" | "info" | "muted";
}) => {
  const map = {
    destructive: "border-destructive/20 bg-destructive-soft text-destructive",
    warning: "border-warning/20 bg-warning-soft text-warning",
    info: "border-info/20 bg-info-soft text-info",
    muted: "border-border bg-surface-muted text-muted-foreground",
  } as const;
  return (
    <div className={cn("surface-card p-4 border", map[tone].split(" ")[0])}>
      <div className="flex items-center justify-between">
        <div className={cn("inline-flex h-7 w-7 items-center justify-center rounded-md", map[tone])}>
          {icon}
        </div>
        <ArrowUpRight className="h-3.5 w-3.5 text-muted-foreground" />
      </div>
      <div className="mt-3 text-3xl font-semibold tracking-tight tabular-nums">{value}</div>
      <div className="text-[11px] text-eyebrow mt-1">{label}</div>
      <div className="text-[11px] text-muted-foreground mt-0.5">{hint}</div>
    </div>
  );
};

const TimelineStep = ({
  tone,
  time,
  title,
  detail,
  active,
}: {
  tone: "success" | "info" | "warning" | "destructive" | "muted";
  time: string;
  title: string;
  detail: string;
  active?: boolean;
}) => {
  const map = {
    success: "bg-success",
    info: "bg-info",
    warning: "bg-warning",
    destructive: "bg-destructive",
    muted: "bg-border-strong",
  };
  return (
    <li className="relative flex gap-3">
      <span
        className={cn(
          "relative z-10 mt-1 inline-flex h-3 w-3 shrink-0 rounded-full ring-4 ring-surface",
          map[tone],
          active && "animate-pulse-dot"
        )}
      />
      <div className="min-w-0 flex-1">
        <div className="flex items-center justify-between gap-2">
          <span className={cn("text-[13px] font-semibold", active ? "text-destructive" : "text-foreground")}>
            {title}
          </span>
          <span className="text-[11px] font-mono text-muted-foreground">{time}</span>
        </div>
        <p className="text-[12px] text-muted-foreground mt-0.5">{detail}</p>
      </div>
    </li>
  );
};

export default SLA;
