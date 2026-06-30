/**
 * Map a caught form-submit error to a user-facing message.
 *
 * - Errors *we* throw after a non-ok API response are plain `Error`s carrying a
 *   curated, user-friendly message → pass it through.
 * - A network/connection failure makes `fetch` reject with a `TypeError`
 *   (e.g. "Failed to fetch") — too technical to show a visitor → replace it
 *   with a friendly connection message.
 * - Anything else (non-Error throwable) → same friendly fallback.
 */
export function formErrorMessage(err: unknown): string {
  if (err instanceof Error && !(err instanceof TypeError)) return err.message;
  return "Couldn't reach us — please check your connection and try again.";
}
