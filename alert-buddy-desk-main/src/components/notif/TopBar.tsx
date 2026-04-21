import { Link } from "react-router-dom";
import { useApp, currentUser } from "@/store/app";
import { Search, ChevronDown, Menu } from "lucide-react";
import { BellMenu } from "./BellMenu";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import type { Role } from "@/data/mock";
import { cn } from "@/lib/utils";

const TITLE_MAP: Record<string, string> = {
  "/": "Inbox",
  "/sla": "SLA Dashboard",
  "/rules": "Notification Rules",
  "/templates": "Templates",
  "/preferences": "My Preferences",
  "/audit": "Audit & Delivery",
};

const ROLE_META: Record<Role, { label: string; sub: string; tone: string }> = {
  requester: { label: "Requester", sub: "Employee view", tone: "bg-info-soft text-info" },
  technician: { label: "Technician", sub: "Service desk view", tone: "bg-accent text-accent-foreground" },
  supervisor: { label: "Supervisor", sub: "Admin view", tone: "bg-warning-soft text-warning" },
};

export const TopBar = ({ pathname }: { pathname: string }) => {
  const role = useApp((s) => s.role);
  const setRole = useApp((s) => s.setRole);
  const user = currentUser(role);
  const title = TITLE_MAP[pathname] ?? "Inbox";

  return (
    <header className="h-14 border-b border-border bg-surface/80 backdrop-blur supports-[backdrop-filter]:bg-surface/70 sticky top-0 z-30">
      <div className="flex h-full items-center gap-3 px-4 sm:px-6">
        <Link to="/" className="md:hidden flex items-center gap-2">
          <Menu className="h-5 w-5 text-muted-foreground" />
        </Link>
        <h1 className="text-[15px] font-semibold text-foreground truncate">{title}</h1>

        <div className="hidden lg:flex relative ml-6 max-w-md flex-1">
          <Search className="absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type="search"
            placeholder="Search tickets, notifications, rules…"
            aria-label="Search"
            className="w-full rounded-md border border-input bg-background pl-9 pr-3 py-1.5 text-sm placeholder:text-muted-foreground focus-ring"
          />
        </div>

        <div className="ml-auto flex items-center gap-2">
          <BellMenu />

          <DropdownMenu>
            <DropdownMenuTrigger className="flex items-center gap-2 rounded-md border border-border bg-background px-2 py-1.5 text-sm hover:bg-muted focus-ring">
              <span
                className={cn(
                  "flex h-7 w-7 items-center justify-center rounded-full text-[11px] font-semibold",
                  ROLE_META[role].tone
                )}
              >
                {user.avatar}
              </span>
              <span className="hidden sm:flex flex-col items-start leading-tight">
                <span className="text-[12px] font-semibold">{user.name.split(" ")[0]}</span>
                <span className="text-[10px] text-muted-foreground">{ROLE_META[role].label}</span>
              </span>
              <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-64">
              <DropdownMenuLabel className="flex items-center gap-2.5">
                <span className={cn("flex h-8 w-8 items-center justify-center rounded-full text-xs font-semibold", ROLE_META[role].tone)}>
                  {user.avatar}
                </span>
                <div className="leading-tight">
                  <div className="text-sm font-semibold">{user.name}</div>
                  <div className="text-[11px] text-muted-foreground">{user.email}</div>
                </div>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuLabel className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                Switch demo role
              </DropdownMenuLabel>
              {(Object.keys(ROLE_META) as Role[]).map((r) => (
                <DropdownMenuItem key={r} onClick={() => setRole(r)} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className={cn("h-2 w-2 rounded-full", role === r ? "bg-primary" : "bg-muted")} />
                    <div className="leading-tight">
                      <div className="text-sm">{ROLE_META[r].label}</div>
                      <div className="text-[11px] text-muted-foreground">{ROLE_META[r].sub}</div>
                    </div>
                  </div>
                  {role === r && <span className="text-[10px] font-semibold text-primary">CURRENT</span>}
                </DropdownMenuItem>
              ))}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
};
