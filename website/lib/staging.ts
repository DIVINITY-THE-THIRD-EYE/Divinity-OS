// Staging placeholders (content/*.ts) are labeled "[STAGING]" / "[STAGING
// CONTENT]" and are meant for the staging environment only — never visitors.
// In production these must resolve to empty so the routes' built-in empty
// states render instead of leaking the placeholder text. A single env flag
// (NEXT_PUBLIC_SHOW_STAGING=1) opts staging env back in.
const SHOW_STAGING = process.env.NEXT_PUBLIC_SHOW_STAGING === "1";

/**
 * Returns `items` verbatim when staging is enabled, otherwise drops any entry
 * whose text fields start with a "[STAGING" marker. `fields` names the string
 * keys to inspect (e.g. "title", "quote").
 */
export function stripStaging<T>(items: T[], fields: (keyof T)[]): T[] {
  if (SHOW_STAGING) return items;
  return items.filter(
    (item) =>
      !fields.some((f) => String(item[f] ?? "").trimStart().startsWith("[STAGING"))
  );
}
