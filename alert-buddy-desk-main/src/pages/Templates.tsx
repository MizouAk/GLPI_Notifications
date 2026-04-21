import { useMemo, useState } from "react";
import { useApp } from "@/store/app";
import { EVENT_LABEL, type NotificationTemplate } from "@/data/mock";
import { Edit3, Eye, FileCode2, Languages, Save } from "lucide-react";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

const SAMPLE = {
  ticket_id: "INC-10042",
  title: "VPN connection drops every 10 minutes from Lyon office",
  requester: "Amélie Roussel",
  requester_first_name: "Amélie",
  assignee: "Marcus Okonkwo",
  group: "IT — Network",
  priority: "High",
  status: "In progress",
  sla_due_at: "Today 16:30 CET",
  overdue_minutes: "25",
  amount: "€1,840",
};

const renderTemplate = (str: string, data: Record<string, string>) =>
  str.replace(/\{\{(\w+)\}\}/g, (_, k) => data[k] ?? `{{${k}}}`);

const renderMarkdown = (md: string) =>
  md
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/`(.+?)`/g, "<code>$1</code>")
    .replace(/^> (.+)$/gm, "<blockquote>$1</blockquote>")
    .replace(/\n\n/g, "</p><p>")
    .replace(/^(.*)$/, "<p>$1</p>");

const Templates = () => {
  const { templates, upsertTemplate } = useApp();
  const [activeId, setActiveId] = useState(templates[0]?.id);
  const active = templates.find((t) => t.id === activeId)!;
  const [draft, setDraft] = useState<NotificationTemplate>(active);

  // sync when switching
  if (active && draft.id !== active.id) setDraft(active);

  const renderedSubject = useMemo(() => renderTemplate(draft.subject, SAMPLE), [draft.subject]);
  const renderedBody = useMemo(() => renderMarkdown(renderTemplate(draft.body, SAMPLE)), [draft.body]);

  return (
    <div className="space-y-5 animate-fade-in">
      <div>
        <div className="text-eyebrow">Admin · Content</div>
        <h2 className="mt-1 text-2xl font-semibold tracking-tight">Notification Templates</h2>
        <p className="text-sm text-muted-foreground mt-1">
          Reusable subjects and bodies with variables. Live preview uses sample ticket data.
        </p>
      </div>

      <div className="grid lg:grid-cols-[280px_1fr] gap-5">
        {/* List */}
        <div className="surface-card overflow-hidden">
          <div className="px-3 py-2.5 border-b border-border text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
            {templates.length} templates
          </div>
          <ul>
            {templates.map((t) => (
              <li key={t.id}>
                <button
                  onClick={() => setActiveId(t.id)}
                  className={cn(
                    "w-full text-left px-3 py-3 border-b border-border last:border-b-0 hover:bg-muted/60 focus-ring transition-colors",
                    activeId === t.id && "bg-accent/40"
                  )}
                >
                  <div className="flex items-center gap-2">
                    <FileCode2 className="h-3.5 w-3.5 text-muted-foreground" />
                    <span className="text-sm font-medium truncate">{t.name}</span>
                  </div>
                  <div className="mt-1 flex items-center gap-2 text-[11px] text-muted-foreground">
                    <span>{EVENT_LABEL[t.event]}</span>
                    <span>·</span>
                    <span className="capitalize">{t.role}</span>
                    <span>·</span>
                    <span className="uppercase">{t.language}</span>
                  </div>
                </button>
              </li>
            ))}
          </ul>
        </div>

        {/* Editor + preview */}
        <div className="grid md:grid-cols-2 gap-5">
          <div className="surface-card overflow-hidden flex flex-col">
            <div className="flex items-center gap-2 border-b border-border px-4 py-2.5">
              <Edit3 className="h-3.5 w-3.5 text-muted-foreground" />
              <span className="text-sm font-semibold">Editor</span>
              <button
                onClick={() => {
                  upsertTemplate({ ...draft, updatedAt: new Date().toISOString() });
                  toast.success("Template saved");
                }}
                className="ml-auto inline-flex items-center gap-1.5 rounded-md bg-primary px-2.5 py-1 text-xs font-semibold text-primary-foreground hover:bg-primary-hover focus-ring"
              >
                <Save className="h-3.5 w-3.5" /> Save
              </button>
            </div>
            <div className="p-4 space-y-3 flex-1">
              <Labelled label="Subject">
                <input
                  value={draft.subject}
                  onChange={(e) => setDraft({ ...draft, subject: e.target.value })}
                  className="w-full rounded-md border border-input bg-background px-3 py-1.5 text-sm font-mono focus-ring"
                />
              </Labelled>

              <div className="grid grid-cols-2 gap-3">
                <Labelled label="Audience role">
                  <select
                    value={draft.role}
                    onChange={(e) => setDraft({ ...draft, role: e.target.value as NotificationTemplate["role"] })}
                    className="w-full rounded-md border border-input bg-background px-2 py-1.5 text-sm focus-ring"
                  >
                    <option value="all">All roles</option>
                    <option value="requester">Requester</option>
                    <option value="technician">Technician</option>
                    <option value="supervisor">Supervisor</option>
                  </select>
                </Labelled>
                <Labelled label="Language">
                  <div className="relative">
                    <Languages className="absolute left-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                    <select
                      value={draft.language}
                      onChange={(e) => setDraft({ ...draft, language: e.target.value as NotificationTemplate["language"] })}
                      className="w-full rounded-md border border-input bg-background pl-7 pr-2 py-1.5 text-sm focus-ring"
                    >
                      <option value="en">English</option>
                      <option value="fr">Français</option>
                      <option value="pt">Português</option>
                    </select>
                  </div>
                </Labelled>
              </div>

              <Labelled label="Body (Markdown · variables in {{double_braces}})">
                <textarea
                  value={draft.body}
                  onChange={(e) => setDraft({ ...draft, body: e.target.value })}
                  rows={12}
                  className="w-full rounded-md border border-input bg-background px-3 py-2 text-[12.5px] font-mono leading-relaxed focus-ring scroll-thin"
                />
              </Labelled>

              <div className="flex flex-wrap gap-1">
                {Object.keys(SAMPLE).map((k) => (
                  <button
                    key={k}
                    onClick={() => setDraft({ ...draft, body: draft.body + ` {{${k}}}` })}
                    className="rounded border border-border bg-surface-muted px-1.5 py-0.5 text-[10.5px] font-mono text-muted-foreground hover:text-foreground hover:border-primary/50 focus-ring"
                  >
                    {`{{${k}}}`}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="surface-card overflow-hidden flex flex-col">
            <div className="flex items-center gap-2 border-b border-border px-4 py-2.5 bg-surface-muted">
              <Eye className="h-3.5 w-3.5 text-muted-foreground" />
              <span className="text-sm font-semibold">Live preview</span>
              <span className="ml-auto text-[10.5px] text-muted-foreground">Sample data</span>
            </div>
            <div className="p-4 flex-1">
              <div className="rounded-lg border border-border bg-background overflow-hidden">
                <div className="border-b border-border bg-surface-muted px-4 py-2.5">
                  <div className="text-[10.5px] uppercase tracking-wider text-muted-foreground">From</div>
                  <div className="text-sm font-medium">GLPI Notifications &lt;notify@acme.eu&gt;</div>
                  <div className="mt-1.5 text-[10.5px] uppercase tracking-wider text-muted-foreground">Subject</div>
                  <div className="text-[14px] font-semibold leading-snug">{renderedSubject}</div>
                </div>
                <div
                  className="prose prose-sm max-w-none px-5 py-4 text-[13.5px] text-foreground/90 leading-relaxed [&_strong]:text-foreground [&_blockquote]:border-l-2 [&_blockquote]:border-border [&_blockquote]:pl-3 [&_blockquote]:italic [&_blockquote]:text-muted-foreground [&_p]:my-2 [&_code]:rounded [&_code]:bg-muted [&_code]:px-1 [&_code]:py-0.5 [&_code]:text-[12px]"
                  dangerouslySetInnerHTML={{ __html: renderedBody }}
                />
              </div>
              <p className="mt-3 text-[11px] text-muted-foreground">
                Unsubscribe and footer are appended automatically by the delivery service.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const Labelled = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <div>
    <label className="block text-[11px] font-semibold uppercase tracking-wider text-muted-foreground mb-1">
      {label}
    </label>
    {children}
  </div>
);

export default Templates;
