// Shared input validators (used by the API routes; kept here so the rule lives
// in one place rather than being duplicated per route).

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/** Loose, dependency-free email shape check (not RFC-exhaustive by design). */
export function isEmail(value: string): boolean {
  return EMAIL_RE.test(value);
}

/** Coerce untrusted JSON values to a string without throwing on objects/null. */
export function asString(value: unknown): string {
  return typeof value === "string" ? value : "";
}

/** True only for a plain (non-null, non-array) JSON object. */
export function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Early-reject oversized request bodies by their declared Content-Length, before
 * `req.json()` buffers the whole stream into memory. A spoofed/absent header
 * (e.g. chunked encoding) simply falls through to the per-field length guards,
 * so this is defense-in-depth, not the only limit. Default cap is generous
 * versus the largest legitimate payload (a ~4KB message + a few short fields).
 */
export function declaredBodyTooLarge(req: Request, maxBytes = 16_384): boolean {
  const len = Number(req.headers.get("content-length"));
  return Number.isFinite(len) && len > maxBytes;
}
