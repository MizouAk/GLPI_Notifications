import { NavLink, Outlet, useLocation } from "react-router-dom";
import {
  Bell,
  Inbox,
  Settings2,
  GaugeCircle,
  ClipboardList,
  ScrollText,
  FileCode2,
  ShieldCheck,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { TopBar } from "./TopBar";

const NAV = [
  { to: "/", label: "Inbox", icon: Inbox, end: true },
  { to: "/sla", label: "SLA Dashboard", icon: GaugeCircle },
  { to: "/rules", label: "Notification Rules", icon: ClipboardList },
  { to: "/templates", label: "Templates", icon: FileCode2 },
  { to: "/preferences", label: "My Preferences", icon: Settings2 },
  { to: "/audit", label: "Audit & Delivery", icon: ScrollText },
];

export const AppLayout = () => {
  const { pathname } = useLocation();
  return (
    <div className="flex h-screen overflow-hidden bg-background">
      {/* Sidebar */}
      <aside className="hidden md:flex w-60 shrink-0 flex-col bg-sidebar text-sidebar-foreground border-r border-sidebar-border">
        <div className="flex items-center gap-2.5 px-5 h-14 border-b border-sidebar-border">
          <div className="flex h-7 w-7 items-center justify-center rounded-md bg-sidebar-primary">
            <Bell className="h-4 w-4 text-sidebar-primary-foreground" />
          </div>
          <div className="leading-tight">
            <div className="text-[13px] font-semibold text-white">GLPI Notify</div>
            <div className="text-[10px] text-sidebar-foreground/60 uppercase tracking-wider">Console</div>
          </div>
        </div>
        <nav className="flex-1 px-2 py-3 space-y-0.5 overflow-y-auto scroll-thin">
          <div className="px-3 pt-2 pb-1 text-[10px] font-semibold uppercase tracking-wider text-sidebar-foreground/50">
            Workspace
          </div>
          {NAV.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                cn(
                  "flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium transition-colors focus-ring",
                  isActive
                    ? "bg-sidebar-accent text-white"
                    : "text-sidebar-foreground hover:bg-sidebar-accent/60 hover:text-white"
                )
              }
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="border-t border-sidebar-border p-3">
          <div className="flex items-center gap-2 rounded-md bg-sidebar-accent/40 p-2.5">
            <ShieldCheck className="h-4 w-4 text-sidebar-primary" />
            <div className="text-[11px] leading-tight text-sidebar-foreground/80">
              All notifications respect quiet hours and consent.
            </div>
          </div>
        </div>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <TopBar pathname={pathname} />
        <main className="flex-1 overflow-y-auto scroll-thin">
          <div className="mx-auto w-full max-w-[1280px] px-4 sm:px-6 lg:px-8 py-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
};
