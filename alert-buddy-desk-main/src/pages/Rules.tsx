import { useState } from "react";
import { useApp } from "@/store/app";
import { EVENT_LABEL, type Channel, type EventType, type NotificationRule, type Priority } from "@/data/mock";
import { ChannelIcon } from "@/components/notif/Badges";
import { relTime } from "@/lib/time";
import {
  ArrowDown,
  ArrowUp,
  Edit3,
  GripVertical,
  Mail,
  MessageSquare,
  Plus,
  Send,
  Trash2,
  Zap,
} from "lucide-react";
import { Switch } from "@/components/ui/switch";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
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

const Rules = () => {
  const { rules, toggleRule, upsertRule, deleteRule } = useApp();
  const [editing, setEditing] = useState<NotificationRule | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<NotificationRule | null>(null);

  const sorted = [...rules].sort((a, b) => a.order - b.order);

  const move = (id: string, dir: -1 | 1) => {
    const idx = sorted.findIndex((r) => r.id === id);
    const target = sorted[idx + dir];
    if (!target) return;
    upsertRule({ ...sorted[idx], order: target.order });
    upsertRule({ ...target, order: sorted[idx].order });
  };

  return (
    <div className="space-y-5 animate-fade-in">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <div className="text-eyebrow">Admin · Routing</div>
          <h2 className="mt-1 text-2xl font-semibold tracking-tight">Notification Rules</h2>
          <p className="text-sm text-muted-foreground mt-1">
            Rules run top-to-bottom on every ticket event. The first matching rule defines who gets notified.
          </p>
        </div>
        <button
          onClick={() =>
            setEditing({
              id: `r_${Date.now()}`,
              name: "",
              enabled: true,
              order: rules.length + 1,
              trigger: "ticket_created",
              conditions: {},
              recipients: { requester: false, assignee: true, group: false, manager: false, customEmails: [] },
              channels: ["in_app"],
              template: "tpl_critical_created",
              lastEdited: new Date().toISOString(),
              editor: "You",
            })
          }
          className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground hover:bg-primary-hover focus-ring shadow-sm"
        >
          <Plus className="h-4 w-4" /> New rule
        </button>
      </div>

      <div className="surface-card overflow-hidden">
        <div className="grid grid-cols-[40px_36px_1fr_140px_160px_140px_120px] gap-3 px-4 py-2 border-b border-border bg-surface-muted text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
          <span />
          <span>On</span>
          <span>Rule</span>
          <span>Trigger</span>
          <span>Recipients</span>
          <span>Channels</span>
          <span className="text-right">Actions</span>
        </div>
        {sorted.map((r, i) => (
          <div key={r.id} className="data-row grid grid-cols-[40px_36px_1fr_140px_160px_140px_120px] gap-3 items-center px-4 py-3">
            <div className="flex flex-col gap-0.5 text-muted-foreground">
              <button
                onClick={() => move(r.id, -1)}
                disabled={i === 0}
                aria-label="Move up"
                className="hover:text-foreground disabled:opacity-30 focus-ring rounded"
              >
                <ArrowUp className="h-3 w-3" />
              </button>
              <GripVertical className="h-3 w-3" />
              <button
                onClick={() => move(r.id, 1)}
                disabled={i === sorted.length - 1}
                aria-label="Move down"
                className="hover:text-foreground disabled:opacity-30 focus-ring rounded"
              >
                <ArrowDown className="h-3 w-3" />
              </button>
            </div>

            <Switch checked={r.enabled} onCheckedChange={() => toggleRule(r.id)} aria-label={`Toggle ${r.name}`} />

            <div className="min-w-0">
              <div className="text-sm font-semibold truncate">{r.name}</div>
              <div className="text-[11px] text-muted-foreground truncate">
                Edited {relTime(r.lastEdited)} by {r.editor}
                {r.conditions.priorities?.length ? ` · priorities: ${r.conditions.priorities.join(", ")}` : ""}
              </div>
            </div>

            <span className="inline-flex items-center gap-1 rounded-md bg-accent px-1.5 py-0.5 text-[11px] font-medium text-accent-foreground w-fit">
              <Zap className="h-3 w-3" /> {EVENT_LABEL[r.trigger]}
            </span>

            <div className="flex flex-wrap gap-1">
              {r.recipients.requester && <Chip>Requester</Chip>}
              {r.recipients.assignee && <Chip>Assignee</Chip>}
              {r.recipients.group && <Chip>Group</Chip>}
              {r.recipients.manager && <Chip>Manager</Chip>}
              {r.recipients.customEmails.length > 0 && <Chip>+{r.recipients.customEmails.length} email</Chip>}
            </div>

            <div className="flex items-center gap-1.5">
              {r.channels.map((c) => (
                <span
                  key={c}
                  className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-1.5 py-0.5 text-[11px] text-muted-foreground"
                  title={c}
                >
                  <ChannelIcon channel={c} />
                </span>
              ))}
            </div>

            <div className="flex justify-end gap-1">
              <IconBtn aria-label="Send test" onClick={() => toast.success(`Test sent for "${r.name}"`)}>
                <Send className="h-3.5 w-3.5" />
              </IconBtn>
              <IconBtn aria-label="Edit" onClick={() => setEditing(r)}>
                <Edit3 className="h-3.5 w-3.5" />
              </IconBtn>
              <IconBtn aria-label="Delete" tone="destructive" onClick={() => setConfirmDelete(r)}>
                <Trash2 className="h-3.5 w-3.5" />
              </IconBtn>
            </div>
          </div>
        ))}
      </div>

      <RuleEditor rule={editing} onClose={() => setEditing(null)} onSave={(r) => { upsertRule(r); toast.success("Rule saved"); setEditing(null); }} />

      <AlertDialog open={!!confirmDelete} onOpenChange={(o) => !o && setConfirmDelete(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete rule "{confirmDelete?.name}"?</AlertDialogTitle>
            <AlertDialogDescription>
              Deleting a rule stops all future notifications matching its trigger and conditions. This can't be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (confirmDelete) {
                  deleteRule(confirmDelete.id);
                  toast.success("Rule deleted");
                  setConfirmDelete(null);
                }
              }}
              className="bg-destructive hover:bg-destructive/90"
            >
              Delete rule
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

const Chip = ({ children }: { children: React.ReactNode }) => (
  <span className="inline-flex items-center rounded border border-border bg-background px-1.5 py-0.5 text-[10.5px] font-medium text-foreground/80">
    {children}
  </span>
);

const IconBtn = ({
  children,
  tone,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { tone?: "destructive" }) => (
  <button
    {...props}
    className={cn(
      "inline-flex h-7 w-7 items-center justify-center rounded border border-border bg-background hover:bg-muted focus-ring",
      tone === "destructive" && "text-destructive hover:bg-destructive-soft border-destructive/20"
    )}
  />
);

const RuleEditor = ({
  rule,
  onClose,
  onSave,
}: {
  rule: NotificationRule | null;
  onClose: () => void;
  onSave: (r: NotificationRule) => void;
}) => {
  const [draft, setDraft] = useState<NotificationRule | null>(rule);
  // sync when opening a new rule
  if (rule && (!draft || draft.id !== rule.id)) setDraft(rule);
  if (!rule || !draft) return null;

  const set = <K extends keyof NotificationRule>(k: K, v: NotificationRule[K]) =>
    setDraft({ ...draft, [k]: v });

  const setRecipient = (k: keyof NotificationRule["recipients"], v: boolean) =>
    setDraft({ ...draft, recipients: { ...draft.recipients, [k]: v } });

  const toggleChannel = (c: Channel) =>
    setDraft({
      ...draft,
      channels: draft.channels.includes(c) ? draft.channels.filter((x) => x !== c) : [...draft.channels, c],
    });

  const togglePriority = (p: Priority) => {
    const cur = draft.conditions.priorities ?? [];
    setDraft({
      ...draft,
      conditions: {
        ...draft.conditions,
        priorities: cur.includes(p) ? cur.filter((x) => x !== p) : [...cur, p],
      },
    });
  };

  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>{rule.name ? `Edit rule` : "New rule"}</DialogTitle>
          <DialogDescription>
            Define when this rule fires and who gets notified. Test before activating.
          </DialogDescription>
        </DialogHeader>

        <div className="grid gap-4 py-2 max-h-[60vh] overflow-y-auto pr-1">
          <Field label="Rule name">
            <input
              value={draft.name}
              onChange={(e) => set("name", e.target.value)}
              placeholder="e.g. SLA breach → on-call manager"
              className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            />
          </Field>

          <div className="grid grid-cols-2 gap-4">
            <Field label="Trigger event">
              <select
                value={draft.trigger}
                onChange={(e) => set("trigger", e.target.value as EventType)}
                className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
              >
                {(Object.keys(EVENT_LABEL) as EventType[]).map((e) => (
                  <option key={e} value={e}>
                    {EVENT_LABEL[e]}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Template">
              <select
                value={draft.template}
                onChange={(e) => set("template", e.target.value)}
                className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
              >
                <option value="tpl_critical_created">Critical ticket created</option>
                <option value="tpl_sla_warning">SLA warning — 30 min</option>
                <option value="tpl_sla_breach">SLA breach escalation</option>
                <option value="tpl_solved_requester">Ticket solved — confirmation</option>
                <option value="tpl_approval_request">Approval requested</option>
              </select>
            </Field>
          </div>

          <Field label="Conditions — match priority (any of)">
            <div className="flex flex-wrap gap-1.5">
              {(["low", "medium", "high", "critical"] as Priority[]).map((p) => {
                const active = draft.conditions.priorities?.includes(p);
                return (
                  <button
                    key={p}
                    onClick={() => togglePriority(p)}
                    className={cn(
                      "rounded-md border px-2 py-1 text-xs font-medium capitalize focus-ring transition-colors",
                      active
                        ? "border-primary bg-accent text-accent-foreground"
                        : "border-border bg-background text-muted-foreground hover:text-foreground"
                    )}
                  >
                    {p}
                  </button>
                );
              })}
            </div>
          </Field>

          <Field label="Recipients">
            <div className="grid grid-cols-2 gap-2">
              {(
                [
                  ["requester", "Requester"],
                  ["assignee", "Assigned technician"],
                  ["group", "Assigned group"],
                  ["manager", "Manager of requester"],
                ] as const
              ).map(([key, label]) => (
                <label
                  key={key}
                  className="flex items-center gap-2 rounded-md border border-border bg-background px-3 py-2 text-sm hover:bg-muted cursor-pointer"
                >
                  <input
                    type="checkbox"
                    checked={draft.recipients[key]}
                    onChange={(e) => setRecipient(key, e.target.checked)}
                    className="h-4 w-4 rounded border-border-strong text-primary focus-ring"
                  />
                  {label}
                </label>
              ))}
            </div>
            <input
              value={draft.recipients.customEmails.join(", ")}
              onChange={(e) =>
                setDraft({
                  ...draft,
                  recipients: {
                    ...draft.recipients,
                    customEmails: e.target.value
                      .split(",")
                      .map((s) => s.trim())
                      .filter(Boolean),
                  },
                })
              }
              placeholder="Custom emails, comma separated"
              className="mt-2 w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm focus-ring"
            />
          </Field>

          <Field label="Channels">
            <div className="flex flex-wrap gap-1.5">
              {(["in_app", "email", "sms"] as Channel[]).map((c) => {
                const active = draft.channels.includes(c);
                return (
                  <button
                    key={c}
                    onClick={() => toggleChannel(c)}
                    className={cn(
                      "inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs font-medium focus-ring transition-colors",
                      active
                        ? "border-primary bg-accent text-accent-foreground"
                        : "border-border bg-background text-muted-foreground"
                    )}
                  >
                    {c === "email" ? <Mail className="h-3.5 w-3.5" /> : c === "sms" ? <MessageSquare className="h-3.5 w-3.5" /> : <Zap className="h-3.5 w-3.5" />}
                    {c === "in_app" ? "In-app" : c === "email" ? "Email" : "SMS / WhatsApp"}
                  </button>
                );
              })}
            </div>
          </Field>
        </div>

        <DialogFooter className="gap-2 sm:gap-2">
          <button
            onClick={() => toast.success(`Test notification sent using "${draft.template}"`)}
            className="inline-flex items-center gap-1.5 rounded-md border border-border bg-background px-3 py-2 text-sm font-medium hover:bg-muted focus-ring"
          >
            <Send className="h-3.5 w-3.5" /> Send test
          </button>
          <button
            onClick={onClose}
            className="rounded-md border border-border bg-background px-3 py-2 text-sm font-medium hover:bg-muted focus-ring"
          >
            Cancel
          </button>
          <button
            onClick={() => onSave({ ...draft, lastEdited: new Date().toISOString(), editor: "You" })}
            className="rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground hover:bg-primary-hover focus-ring"
          >
            Save rule
          </button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

const Field = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <div>
    <label className="block text-[11px] font-semibold uppercase tracking-wider text-muted-foreground mb-1.5">
      {label}
    </label>
    {children}
  </div>
);

export default Rules;
