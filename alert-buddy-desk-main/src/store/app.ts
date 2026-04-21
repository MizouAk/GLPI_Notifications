import { create } from "zustand";
import {
  NOTIFICATIONS,
  RULES,
  TEMPLATES,
  PREFERENCES,
  DELIVERY_LOGS,
  USERS,
  type Notification,
  type NotificationRule,
  type NotificationTemplate,
  type UserPreferences,
  type DeliveryLog,
  type Role,
} from "@/data/mock";

interface AppState {
  role: Role;
  setRole: (r: Role) => void;
  notifications: Notification[];
  rules: NotificationRule[];
  templates: NotificationTemplate[];
  preferences: UserPreferences;
  logs: DeliveryLog[];

  markRead: (ids: string[], read?: boolean) => void;
  archive: (ids: string[]) => void;
  remove: (ids: string[]) => void;

  toggleRule: (id: string) => void;
  upsertRule: (rule: NotificationRule) => void;
  deleteRule: (id: string) => void;

  upsertTemplate: (t: NotificationTemplate) => void;

  updatePreferences: (p: Partial<UserPreferences>) => void;

  retryDelivery: (id: string) => void;
}

export const useApp = create<AppState>((set) => ({
  role: "technician",
  setRole: (role) => set({ role }),
  notifications: NOTIFICATIONS,
  rules: RULES,
  templates: TEMPLATES,
  preferences: PREFERENCES,
  logs: DELIVERY_LOGS,

  markRead: (ids, read = true) =>
    set((s) => ({
      notifications: s.notifications.map((n) =>
        ids.includes(n.id) ? { ...n, read } : n
      ),
    })),
  archive: (ids) =>
    set((s) => ({
      notifications: s.notifications.map((n) =>
        ids.includes(n.id) ? { ...n, archived: true, read: true } : n
      ),
    })),
  remove: (ids) =>
    set((s) => ({
      notifications: s.notifications.filter((n) => !ids.includes(n.id)),
    })),

  toggleRule: (id) =>
    set((s) => ({
      rules: s.rules.map((r) => (r.id === id ? { ...r, enabled: !r.enabled } : r)),
    })),
  upsertRule: (rule) =>
    set((s) => {
      const exists = s.rules.some((r) => r.id === rule.id);
      return {
        rules: exists
          ? s.rules.map((r) => (r.id === rule.id ? rule : r))
          : [...s.rules, rule],
      };
    }),
  deleteRule: (id) =>
    set((s) => ({ rules: s.rules.filter((r) => r.id !== id) })),

  upsertTemplate: (t) =>
    set((s) => ({
      templates: s.templates.some((x) => x.id === t.id)
        ? s.templates.map((x) => (x.id === t.id ? t : x))
        : [...s.templates, t],
    })),

  updatePreferences: (p) =>
    set((s) => ({ preferences: { ...s.preferences, ...p } })),

  retryDelivery: (id) =>
    set((s) => ({
      logs: s.logs.map((l) =>
        l.id === id
          ? {
              ...l,
              status: "delivered" as const,
              attempts: l.attempts + 1,
              deliveredAt: new Date().toISOString(),
              errorReason: undefined,
            }
          : l
      ),
    })),
}));

export const currentUser = (role: Role) => USERS.find((u) => u.role === role)!;
