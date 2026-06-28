// Shared input validators (used by the API routes; kept here so the rule lives
// in one place rather than being duplicated per route).

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** Loose, dependency-free email shape check (not RFC-exhaustive by design). */
export function isEmail(value: string): boolean {
  return EMAIL_RE.test(value);
}
