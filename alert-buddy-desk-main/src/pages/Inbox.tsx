import { useMemo, useState } from "react";
import { useApp } from "@/store/app";
import { EVENT_LABEL, PRIORITY_LABEL, type EventType, type Priority } from "@/data/mock";
import { EventIcon, PriorityBadge, ChannelIcon } from "@/components/notif/Badges";
import { relTime, fullTime } from "@/lib/time";
import { Archive, CheckCheck, Filter, Mail, Trash2, Inbox as InboxIcon, ExternalLink, Search } from "lucide-react";
import { cn } from "@/lib/utils";
import { Checkbox } from "@/components/ui/checkbox";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

type ReadFilter = "all" | "unread" | "read";

const Inbox = () => {
  const { notifications, role, markRead, archive, remove } = useApp();
  const [readFilter, setReadFilter] = useState<ReadFilter>("all");
  const [eventFilter, setEventFilter] = useState<EventType | "all">("all");
  const [priorityFilter, setPriorityFilter] = useState<Priority | "all">("all");
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<string[]>([]);
  const [confirmDelete, setConfirmDelete] = useState(false);

  const filtered = useMemo(() => {
    return notifications
      .filter((n) => !n.archived)
      .filter((n) => n.recipient === role)
      .filter((n) => (readFilter === "unread" ? !n.read : readFilter === "read" ? n.read : true))
      .filter((n) => (eventFilter === "all" ? true : n.event === eventFilter))
      .filter((n) => (priorityFilter === "all" ? true : n.priority === priorityFilter))
      .filter((n) =>
        query
          ? `${n.title} ${n.body} ${n.ticketId} ${n.ticketTitle}`.toLowerCase().includes(query.toLowerCase())
          : true
      );
  }, [notifications, role, readFilter, eventFilter, priorityFilter, query]);

  const allSelected = filtered.length > 0 && selected.length === filtered.length;

  const toggleAll = () =>
    setSelected(allSelected ? [] : filtered.map((n) => n.id));

  const toggleOne = (id: string) =>
    setSelected((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));

  const onMarkRead = () => {
    markRead(selected, true);
    toast.success(`Marked ${selected.length} as read`);
    setSelected([]);
  };
  const onArchive = () => {
    archive(selected);
    toast.success(`Archived ${selected.length} notification${selected.length > 1 ? "s" : ""}`);
    setSelected([]);
  };
  const onDelete = () => {
    remove(selected);
    toast.success(`Deleted ${selected.length} notification${selected.length > 1 ? "s" : ""}`);
    setSelected([]);
    setConfirmDelete(false);
  };

  const unreadCount = notifications.filter((n) => !n.archived && n.recipient === role && !n.read).length;

  return (
    <div className="space-y-5 animate-fade-in">
      {/* Header strip */}
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-eyebrow">Notification center</div>
          <h2 className="mt-1 text-2xl font-semibold tracking-tight">
            Inbox
            <span className="ml-2 inline-flex items-center rounded-md bg-accent px-2 py-0.5 text-xs font-semibold text-accent-foreground align-middle">
              {unreadCount} unread
            </span>
          </h2>
          <p className="text-sm text-muted-foreground mt-1">
            Showing notifications addressed to you, in your current role.
          </p>
        </div>
      </div>

      {/* Filter bar */}
      <div className="surface-card p-3 flex flex-wrap items-center gap-2">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Filter by ticket ID, keyword…"
            className="w-full rounded-md border border-input bg-background pl-9 pr-3 py-1.5 text-sm focus-ring"
            aria-label="Filter notifications"
          />
        </div>

        <FilterPill icon={<Filter className="h-3.5 w-3.5" />}>
          <Select value={readFilter} onValueChange={(v) => setReadFilter(v as ReadFilter)}>
            <SelectTrigger className="h-8 w-[120px] border-0 bg-transparent text-xs focus:ring-0 focus:ring-offset-0">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="unread">Unread</SelectItem>
              <SelectItem value="read">Read</SelectItem>
            </SelectContent>
          </Select>
        </FilterPill>

        <FilterPill label="Event">
          <Select value={eventFilter} onValueChange={(v) => setEventFilter(v as EventType | "all")}>
            <SelectTrigger className="h-8 w-[170px] border-0 bg-transparent text-xs focus:ring-0 focus:ring-offset-0">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Any event</SelectItem>
              {(Object.keys(EVENT_LABEL) as EventType[]).map((e) => (
                <SelectItem key={e} value={e}>
                  {EVENT_LABEL[e]}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </FilterPill>

        <FilterPill label="Priority">
          <Select value={priorityFilter} onValueChange={(v) => setPriorityFilter(v as Priority | "all")}>
            <SelectTrigger className="h-8 w-[120px] border-0 bg-transparent text-xs focus:ring-0 focus:ring-offset-0">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Any</SelectItem>
              {(Object.keys(PRIORITY_LABEL) as Priority[]).map((p) => (
                <SelectItem key={p} value={p}>
                  {PRIORITY_LABEL[p]}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </FilterPill>
      </div>

      {/* Bulk action bar */}
      {selected.length > 0 && (
        <div className="surface-card flex items-center gap-3 px-4 py-2.5 border-primary/30 bg-accent/40">
          <span className="text-sm font-medium">{selected.length} selected</span>
          <div className="ml-auto flex items-center gap-1.5">
            <BulkBtn icon={<CheckCheck className="h-3.5 w-3.5" />} label="Mark read" onClick={onMarkRead} />
            <BulkBtn icon={<Archive className="h-3.5 w-3.5" />} label="Archive" onClick={onArchive} />
            <BulkBtn
              icon={<Trash2 className="h-3.5 w-3.5" />}
              label="Delete"
              onClick={() => setConfirmDelete(true)}
              tone="destructive"
            />
          </div>
        </div>
      )}

      {/* List */}
      <div className="surface-card overflow-hidden">
        <div className="flex items-center gap-3 px-4 py-2 border-b border-border bg-surface-muted text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
          <Checkbox
            checked={allSelected}
            onCheckedChange={toggleAll}
            aria-label="Select all"
            className="border-border-strong"
          />
          <span className="flex-1">{filtered.length} notification{filtered.length === 1 ? "" : "s"}</span>
          <span className="hidden sm:block">Ticket</span>
          <span className="w-24 text-right">Received</span>
        </div>

        {filtered.length === 0 ? (
          <EmptyState />
        ) : (
          <ul>
            {filtered.map((n) => (
              <li key={n.id} className="data-row">
                <div className="flex items-start gap-3 px-4 py-3.5">
                  <Checkbox
                    checked={selected.includes(n.id)}
                    onCheckedChange={() => toggleOne(n.id)}
                    aria-label={`Select ${n.title}`}
                    className="mt-1 border-border-strong"
                  />
                  <EventIcon event={n.event} />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <button
                        onClick={() => markRead([n.id], true)}
                        className={cn(
                          "text-[13.5px] text-foreground hover:text-primary text-left focus-ring rounded",
                          !n.read ? "font-semibold" : "font-normal"
                        )}
                      >
                        {n.title}
                      </button>
                      {!n.read && <span className="h-1.5 w-1.5 rounded-full bg-primary" aria-label="unread" />}
                      <PriorityBadge priority={n.priority} />
                      <span className="inline-flex items-center gap-1 rounded-md border border-border bg-surface-muted px-1.5 py-0.5 text-[10px] text-muted-foreground">
                        <ChannelIcon channel={n.channel} /> {n.channel === "in_app" ? "In-app" : n.channel === "email" ? "Email" : "SMS"}
                      </span>
                    </div>
                    <p className="text-[12.5px] text-muted-foreground mt-0.5 line-clamp-2">{n.body}</p>
                    <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1 text-[11px] text-muted-foreground">
                      <span className="inline-flex items-center gap-1">
                        <span className="font-mono font-semibold text-foreground/80">{n.ticketId}</span>
                        <span className="truncate max-w-[260px]">— {n.ticketTitle}</span>
                      </span>
                      {n.actor && <span>by {n.actor}</span>}
                    </div>
                  </div>
                  <div className="hidden sm:flex flex-col items-end gap-1 text-[11px] text-muted-foreground w-24 shrink-0">
                    <span title={fullTime(n.createdAt)}>{relTime(n.createdAt)}</span>
                    <a
                      href={`#${n.ticketId}`}
                      className="inline-flex items-center gap-1 text-primary hover:text-primary-hover focus-ring rounded"
                      onClick={(e) => {
                        e.preventDefault();
                        toast.info(`Deep link → ${n.ticketId} (mock)`);
                      }}
                    >
                      Open <ExternalLink className="h-3 w-3" />
                    </a>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      <AlertDialog open={confirmDelete} onOpenChange={setConfirmDelete}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete {selected.length} notification{selected.length > 1 ? "s" : ""}?</AlertDialogTitle>
            <AlertDialogDescription>
              This permanently removes them from your inbox. You can&apos;t undo this action.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={onDelete} className="bg-destructive hover:bg-destructive/90">
              Delete permanently
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

const FilterPill = ({ label, icon, children }: { label?: string; icon?: React.ReactNode; children: React.ReactNode }) => (
  <div className="inline-flex items-center gap-1.5 rounded-md border border-border bg-background pl-2 pr-0.5">
    {icon && <span className="text-muted-foreground">{icon}</span>}
    {label && <span className="text-[11px] font-medium text-muted-foreground">{label}</span>}
    {children}
  </div>
);

const BulkBtn = ({
  icon,
  label,
  onClick,
  tone,
}: {
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  tone?: "destructive";
}) => (
  <button
    onClick={onClick}
    className={cn(
      "inline-flex items-center gap-1.5 rounded-md border bg-surface px-2.5 py-1.5 text-xs font-medium transition-colors focus-ring",
      tone === "destructive"
        ? "border-destructive/30 text-destructive hover:bg-destructive-soft"
        : "border-border text-foreground hover:bg-muted"
    )}
  >
    {icon}
    {label}
  </button>
);

const EmptyState = () => (
  <div className="px-6 py-16 text-center">
    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-success-soft">
      <Mail className="h-5 w-5 text-success" />
    </div>
    <h3 className="mt-3 text-sm font-semibold">Nothing matches your filters</h3>
    <p className="mt-1 text-[12.5px] text-muted-foreground">
      Try clearing a filter or switching to another role from the top-right menu.
    </p>
  </div>
);

export default Inbox;
