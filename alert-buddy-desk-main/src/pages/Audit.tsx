import { useMemo, useState } from "react";
import { useApp } from "@/store/app";
import type { DeliveryStatus } from "@/data/mock";
import { ChannelIcon, DeliveryBadge } from "@/components/notif/Badges";
import { fullTime, relTime } from "@/lib/time";
import { Download, RefreshCw, Search, AlertTriangle, ArrowRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";

const Audit = () => {
  const { logs, retryDelivery } = useApp();
  const [statusFilter, setStatusFilter] = useState<DeliveryStatus | "all">("all");
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return logs
      .filter((l) => (statusFilter === "all" ? true : l.status === statusFilter))
      .filter((l) =>
        query
          ? `${l.recipient} ${l.ticketId} ${l.template} ${l.errorReason ?? ""}`
              .toLowerCase()
              .includes(query.toLowerCase())
          : true
      )
      .sort((a, b) => new Date(b.sentAt).getTime() - new Date(a.sentAt).getTime());
  }, [logs, statusFilter, query]);

  const failed = logs.filter((l) => l.status === "failed");

  const exportCsv = () => {
    const header = ["id", "ticket", "recipient", "channel", "template", "status", "attempts", "sentAt", "errorReason"];
    const rows = filtered.map((l) =>
      [l.id, l.ticketId, l.recipient, l.channel, l.template, l.status, l.attempts, l.sentAt, l.errorReason ?? ""]
        .map((v) => `"${String(v).replace(/"/g, '""')}"`)
        .join(",")
    );
    const blob = new Blob([[header.join(","), ...rows].join("\n")], { type: "text/csv" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `notification-logs-${Date.now()}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success(`Exported ${filtered.length} rows`);
  };

  const detail = open ? logs.find((l) => l.id === open) : null;

  return (
    <div className="space-y-5 animate-fade-in">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-eyebrow">Reliability · Observability</div>
          <h2 className="mt-1 text-2xl font-semibold tracking-tight">Audit & Delivery</h2>
          <p className="text-sm text-muted-foreground mt-1">
            Every notification, every attempt — sent, delivered, opened, or failed.
          </p>
        </div>
        <button
          onClick={exportCsv}
          className="inline-flex items-center gap-1.5 rounded-md border border-border bg-background px-3 py-2 text-sm font-medium hover:bg-muted focus-ring"
        >
          <Download className="h-3.5 w-3.5" /> Export CSV
        </button>
      </div>

      {/* Retry queue strip */}
      {failed.length > 0 && (
        <div className="surface-card border-destructive/30 bg-destructive-soft/40 px-4 py-3 flex items-center gap-3">
          <span className="inline-flex h-9 w-9 items-center justify-center rounded-md bg-destructive-soft text-destructive shrink-0">
            <AlertTriangle className="h-4 w-4" />
          </span>
          <div className="flex-1 min-w-0">
            <div className="text-sm font-semibold">{failed.length} failed deliveries waiting for retry</div>
            <div className="text-[12px] text-muted-foreground">
              Last failure: {failed[0].errorReason ?? "Unknown error"}
            </div>
          </div>
          <button
            onClick={() => {
              failed.forEach((l) => retryDelivery(l.id));
              toast.success(`Retried ${failed.length} delivery${failed.length > 1 ? " items" : ""}`);
            }}
            className="inline-flex items-center gap-1.5 rounded-md bg-destructive px-3 py-1.5 text-xs font-semibold text-destructive-foreground hover:bg-destructive/90 focus-ring shrink-0"
          >
            <RefreshCw className="h-3.5 w-3.5" /> Retry all
          </button>
        </div>
      )}

      {/* Filters */}
      <div className="surface-card p-3 flex flex-wrap items-center gap-2">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search by recipient, ticket, template…"
            className="w-full rounded-md border border-input bg-background pl-9 pr-3 py-1.5 text-sm focus-ring"
          />
        </div>
        <div className="flex items-center gap-1 rounded-md border border-border bg-background p-0.5">
          {(["all", "delivered", "opened", "failed", "queued", "sent"] as const).map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn(
                "rounded px-2 py-1 text-xs font-medium capitalize transition-colors focus-ring",
                statusFilter === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground"
              )}
            >
              {s}
            </button>
          ))}
        </div>
      </div>

      {/* Table */}
      <div className="surface-card overflow-hidden">
        <div className="grid grid-cols-[110px_1fr_120px_110px_110px_120px_60px] gap-3 px-4 py-2 border-b border-border bg-surface-muted text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
          <span>Ticket</span>
          <span>Recipient & template</span>
          <span>Channel</span>
          <span>Status</span>
          <span>Attempts</span>
          <span>Sent</span>
          <span />
        </div>
        {filtered.length === 0 ? (
          <div className="px-6 py-16 text-center text-sm text-muted-foreground">No log entries match your filters.</div>
        ) : (
          filtered.map((l) => (
            <button
              key={l.id}
              onClick={() => setOpen(l.id)}
              className="data-row w-full text-left grid grid-cols-[110px_1fr_120px_110px_110px_120px_60px] gap-3 items-center px-4 py-3 focus-ring"
            >
              <span className="font-mono text-[12px] font-semibold text-foreground">{l.ticketId}</span>
              <div className="min-w-0">
                <div className="text-sm font-medium truncate">{l.recipient}</div>
                <div className="text-[11px] text-muted-foreground truncate font-mono">{l.template}</div>
              </div>
              <span className="inline-flex items-center gap-1.5 text-[12px] text-foreground/80 capitalize">
                <ChannelIcon channel={l.channel} /> {l.channel === "in_app" ? "In-app" : l.channel}
              </span>
              <DeliveryBadge status={l.status} />
              <span className="text-[12px] text-muted-foreground tabular-nums">{l.attempts}/3</span>
              <span className="text-[12px] text-muted-foreground" title={fullTime(l.sentAt)}>
                {relTime(l.sentAt)}
              </span>
              <ArrowRight className="h-3.5 w-3.5 text-muted-foreground" />
            </button>
          ))
        )}
      </div>

      <Sheet open={!!detail} onOpenChange={(o) => !o && setOpen(null)}>
        <SheetContent className="w-full sm:max-w-lg overflow-y-auto scroll-thin">
          {detail && (
            <>
              <SheetHeader className="text-left">
                <div className="flex items-center gap-2">
                  <span className="font-mono text-[12px] font-semibold">{detail.ticketId}</span>
                  <DeliveryBadge status={detail.status} />
                </div>
                <SheetTitle className="text-base">Delivery details</SheetTitle>
                <SheetDescription>
                  Notification {detail.notificationId} · Template <span className="font-mono">{detail.template}</span>
                </SheetDescription>
              </SheetHeader>

              <dl className="mt-5 space-y-3 text-sm">
                <Row k="Recipient" v={detail.recipient} />
                <Row k="Channel" v={<span className="capitalize">{detail.channel === "in_app" ? "In-app" : detail.channel}</span>} />
                <Row k="Attempts" v={`${detail.attempts} of 3`} />
                <Row k="Sent at" v={fullTime(detail.sentAt)} />
                {detail.deliveredAt && <Row k="Delivered at" v={fullTime(detail.deliveredAt)} />}
                {detail.openedAt && <Row k="Opened at" v={fullTime(detail.openedAt)} />}
              </dl>

              {detail.errorReason && (
                <div className="mt-5 rounded-md border border-destructive/30 bg-destructive-soft p-3">
                  <div className="text-[11px] font-semibold uppercase tracking-wider text-destructive mb-1">
                    Error reason
                  </div>
                  <p className="text-[13px] text-foreground">{detail.errorReason}</p>
                </div>
              )}

              {detail.status === "failed" && (
                <button
                  onClick={() => {
                    retryDelivery(detail.id);
                    toast.success(`Retry queued for ${detail.ticketId}`);
                    setOpen(null);
                  }}
                  className="mt-4 w-full inline-flex items-center justify-center gap-1.5 rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground hover:bg-primary-hover focus-ring"
                >
                  <RefreshCw className="h-3.5 w-3.5" /> Retry now
                </button>
              )}
            </>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
};

const Row = ({ k, v }: { k: string; v: React.ReactNode }) => (
  <div className="flex items-start justify-between gap-4 border-b border-border pb-2 last:border-b-0">
    <dt className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">{k}</dt>
    <dd className="text-sm text-foreground text-right">{v}</dd>
  </div>
);

export default Audit;
