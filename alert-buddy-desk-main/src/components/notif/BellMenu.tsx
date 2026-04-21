import { Bell, Check, ExternalLink, Settings2 } from "lucide-react";
import { Link } from "react-router-dom";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { useApp } from "@/store/app";
import { EventIcon } from "./Badges";
import { relTime } from "@/lib/time";
import { cn } from "@/lib/utils";

export const BellMenu = () => {
  const notifications = useApp((s) => s.notifications);
  const markRead = useApp((s) => s.markRead);
  const role = useApp((s) => s.role);

  const visible = notifications.filter((n) => !n.archived && (n.recipient === role));
  const unread = visible.filter((n) => !n.read);
  const preview = visible.slice(0, 5);

  return (
    <Popover>
      <PopoverTrigger
        aria-label={`Notifications (${unread.length} unread)`}
        className="relative inline-flex h-9 w-9 items-center justify-center rounded-md border border-border bg-background text-foreground hover:bg-muted focus-ring"
      >
        <Bell className="h-4 w-4" />
        {unread.length > 0 && (
          <span
            aria-hidden
            className="absolute -top-1 -right-1 inline-flex min-w-[18px] h-[18px] items-center justify-center rounded-full bg-destructive px-1 text-[10px] font-bold text-destructive-foreground ring-2 ring-surface"
          >
            {unread.length > 9 ? "9+" : unread.length}
          </span>
        )}
      </PopoverTrigger>
      <PopoverContent align="end" sideOffset={8} className="w-[380px] p-0 overflow-hidden">
        <div className="flex items-center justify-between px-4 py-3 border-b border-border">
          <div>
            <div className="text-sm font-semibold">Notifications</div>
            <div className="text-[11px] text-muted-foreground">
              {unread.length} unread · viewing as {role}
            </div>
          </div>
          <button
            onClick={() => markRead(unread.map((n) => n.id), true)}
            disabled={unread.length === 0}
            className="text-[11px] font-semibold text-primary hover:text-primary-hover disabled:text-muted-foreground disabled:cursor-not-allowed focus-ring rounded px-1"
          >
            Mark all read
          </button>
        </div>

        <ul className="max-h-[420px] overflow-y-auto scroll-thin divide-y divide-border">
          {preview.length === 0 && (
            <li className="px-4 py-10 text-center">
              <Check className="mx-auto h-6 w-6 text-success" />
              <div className="mt-2 text-sm font-medium">You're all caught up</div>
              <div className="text-[11px] text-muted-foreground">No new notifications for this role.</div>
            </li>
          )}
          {preview.map((n) => (
            <li key={n.id}>
              <Link
                to={`/?ticket=${n.ticketId}`}
                onClick={() => markRead([n.id], true)}
                className={cn(
                  "flex gap-3 px-4 py-3 hover:bg-muted/60 transition-colors focus-ring",
                  !n.read && "bg-accent/30"
                )}
              >
                <EventIcon event={n.event} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <span className="text-[13px] font-semibold text-foreground truncate">{n.title}</span>
                    {!n.read && <span className="h-1.5 w-1.5 rounded-full bg-primary shrink-0" aria-label="unread" />}
                  </div>
                  <p className="text-[12px] text-muted-foreground line-clamp-2 mt-0.5">{n.body}</p>
                  <div className="mt-1 flex items-center gap-2 text-[10px] text-muted-foreground">
                    <span className="font-mono font-medium text-foreground/70">{n.ticketId}</span>
                    <span>·</span>
                    <span>{relTime(n.createdAt)}</span>
                  </div>
                </div>
              </Link>
            </li>
          ))}
        </ul>

        <div className="flex items-center justify-between border-t border-border bg-surface-muted px-3 py-2">
          <Link
            to="/preferences"
            className="inline-flex items-center gap-1.5 text-[11px] font-medium text-muted-foreground hover:text-foreground focus-ring rounded px-1"
          >
            <Settings2 className="h-3 w-3" /> Preferences
          </Link>
          <Link
            to="/"
            className="inline-flex items-center gap-1 text-[11px] font-semibold text-primary hover:text-primary-hover focus-ring rounded px-1"
          >
            Open inbox <ExternalLink className="h-3 w-3" />
          </Link>
        </div>
      </PopoverContent>
    </Popover>
  );
};
