import { formatDistanceToNowStrict, format, differenceInMinutes } from "date-fns";

export const relTime = (iso: string) => {
  const d = new Date(iso);
  const diffMin = (Date.now() - d.getTime()) / 60000;
  if (diffMin < 1) return "just now";
  return formatDistanceToNowStrict(d, { addSuffix: true });
};

export const fullTime = (iso: string) => format(new Date(iso), "PP · HH:mm");

export const slaCountdown = (iso: string) => {
  const mins = differenceInMinutes(new Date(iso), new Date());
  if (mins < 0) return { label: `Overdue by ${Math.abs(mins)} min`, overdue: true, mins };
  if (mins < 60) return { label: `Due in ${mins} min`, overdue: false, mins };
  return { label: `Due in ${Math.floor(mins / 60)}h ${mins % 60}m`, overdue: false, mins };
};
