import { useApp } from "@/store/app";
import type { Channel } from "@/data/mock";
import { Switch } from "@/components/ui/switch";
import { ChannelIcon } from "@/components/notif/Badges";
import { Bell, Clock, Globe, MessageSquare, Slash, Zap } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const Preferences = () => {
  const { preferences, updatePreferences } = useApp();

  const channelMeta: { id: Channel; label: string; description: string }[] = [
    { id: "in_app", label: "In-app", description: "Inbox and bell menu inside GLPI." },
    { id: "email", label: "Email", description: "Sent to your work address." },
    { id: "sms", label: "SMS / WhatsApp", description: "For SLA breaches and on-call only." },
  ];

  return (
    <div className="space-y-5 max-w-3xl animate-fade-in">
      <div>
        <div className="text-eyebrow">Personal · Settings</div>
        <h2 className="mt-1 text-2xl font-semibold tracking-tight">My Notification Preferences</h2>
        <p className="text-sm text-muted-foreground mt-1">
          Control how and when you get pinged. Critical SLA alerts always bypass quiet hours.
        </p>
      </div>

      <Section title="Delivery channels" icon={<Bell className="h-4 w-4" />}>
        <div className="divide-y divide-border">
          {channelMeta.map((c) => (
            <div key={c.id} className="flex items-center justify-between py-3">
              <div className="flex items-start gap-3">
                <span className="mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-md bg-accent text-accent-foreground">
                  <ChannelIcon channel={c.id} className="h-4 w-4" />
                </span>
                <div>
                  <div className="text-sm font-medium">{c.label}</div>
                  <div className="text-[12px] text-muted-foreground">{c.description}</div>
                </div>
              </div>
              <Switch
                checked={preferences.channels[c.id]}
                onCheckedChange={(v) =>
                  updatePreferences({ channels: { ...preferences.channels, [c.id]: v } })
                }
                aria-label={`Toggle ${c.label}`}
              />
            </div>
          ))}
        </div>
      </Section>

      <Section title="Frequency" icon={<Zap className="h-4 w-4" />}>
        <div className="grid sm:grid-cols-3 gap-2">
          {(
            [
              { v: "instant", t: "Instant", d: "Get every notification immediately" },
              { v: "hourly_digest", t: "Hourly digest", d: "One bundled email per hour" },
              { v: "daily_summary", t: "Daily summary", d: "One email at 8:00 AM" },
            ] as const
          ).map((opt) => {
            const active = preferences.frequency === opt.v;
            return (
              <button
                key={opt.v}
                onClick={() => updatePreferences({ frequency: opt.v })}
                className={cn(
                  "rounded-lg border p-3 text-left transition-all focus-ring",
                  active
                    ? "border-primary bg-accent/40 ring-2 ring-primary/20"
                    : "border-border bg-background hover:bg-muted"
                )}
              >
                <div className="flex items-center gap-2">
                  <span className={cn("h-2 w-2 rounded-full", active ? "bg-primary" : "bg-border-strong")} />
                  <div className="text-sm font-semibold">{opt.t}</div>
                </div>
                <div className="text-[11.5px] text-muted-foreground mt-1">{opt.d}</div>
              </button>
            );
          })}
        </div>
      </Section>

      <Section title="Quiet hours" icon={<Clock className="h-4 w-4" />}>
        <div className="flex items-start gap-3 mb-3">
          <Switch
            checked={preferences.quietHours.enabled}
            onCheckedChange={(v) => updatePreferences({ quietHours: { ...preferences.quietHours, enabled: v } })}
            aria-label="Toggle quiet hours"
          />
          <div className="text-[12.5px] text-muted-foreground -mt-0.5">
            Pause non-critical notifications during your off-hours. Critical SLA alerts will still come through.
          </div>
        </div>
        <div className={cn("grid grid-cols-2 gap-3", !preferences.quietHours.enabled && "opacity-50 pointer-events-none")}>
          <Labelled label="From">
            <input
              type="time"
              value={preferences.quietHours.from}
              onChange={(e) =>
                updatePreferences({ quietHours: { ...preferences.quietHours, from: e.target.value } })
              }
              className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            />
          </Labelled>
          <Labelled label="To">
            <input
              type="time"
              value={preferences.quietHours.to}
              onChange={(e) =>
                updatePreferences({ quietHours: { ...preferences.quietHours, to: e.target.value } })
              }
              className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            />
          </Labelled>
        </div>
      </Section>

      <Section title="Muted tickets & categories" icon={<Slash className="h-4 w-4" />}>
        <div className="flex flex-wrap gap-1.5 mb-2">
          {preferences.mutedTickets.map((t) => (
            <span
              key={t}
              className="inline-flex items-center gap-1.5 rounded-md border border-border bg-surface-muted px-2 py-1 text-[11.5px] font-mono"
            >
              {t}
              <button
                aria-label={`Unmute ${t}`}
                onClick={() => {
                  updatePreferences({ mutedTickets: preferences.mutedTickets.filter((x) => x !== t) });
                  toast.success(`Unmuted ${t}`);
                }}
                className="text-muted-foreground hover:text-destructive focus-ring rounded"
              >
                ×
              </button>
            </span>
          ))}
          {preferences.mutedTickets.length === 0 && (
            <span className="text-[12px] text-muted-foreground">No muted tickets — quiet, clean inbox.</span>
          )}
        </div>
        <p className="text-[11.5px] text-muted-foreground">
          Mute a ticket from its detail view to stop receiving updates on it.
        </p>
      </Section>

      <Section title="Locale" icon={<Globe className="h-4 w-4" />}>
        <div className="grid sm:grid-cols-2 gap-3">
          <Labelled label="Language">
            <select
              value={preferences.language}
              onChange={(e) => updatePreferences({ language: e.target.value as typeof preferences.language })}
              className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            >
              <option value="en">English</option>
              <option value="fr">Français</option>
              <option value="pt">Português</option>
            </select>
          </Labelled>
          <Labelled label="Timezone">
            <select
              value={preferences.timezone}
              onChange={(e) => updatePreferences({ timezone: e.target.value })}
              className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            >
              <option>Europe/Paris</option>
              <option>Europe/Lisbon</option>
              <option>Europe/London</option>
              <option>America/New_York</option>
              <option>Asia/Tokyo</option>
            </select>
          </Labelled>
        </div>
      </Section>
    </div>
  );
};

const Section = ({ title, icon, children }: { title: string; icon: React.ReactNode; children: React.ReactNode }) => (
  <section className="surface-card p-5">
    <header className="flex items-center gap-2 mb-3">
      <span className="inline-flex h-7 w-7 items-center justify-center rounded-md bg-accent text-accent-foreground">
        {icon}
      </span>
      <h3 className="text-sm font-semibold">{title}</h3>
    </header>
    {children}
  </section>
);

const Labelled = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <div>
    <label className="block text-[11px] font-semibold uppercase tracking-wider text-muted-foreground mb-1">
      {label}
    </label>
    {children}
  </div>
);

export default Preferences;
