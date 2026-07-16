// Role comes from the JWT's app_metadata.role (synced by the DB's
// sync_user_role_to_auth trigger) — trust the claim, never re-derive it with
// a client-side database read (SECURITY NOTES, 12_STUDENT_LOGIN.md).
export type AppRole = "student" | "trainer" | "admin";

type MinimalUser = {
  app_metadata?: Record<string, unknown> | null;
} | null | undefined;

/**
 * True only when the signed-in user's JWT role claim is "student".
 * The DB stores roles uppercase ('STUDENT' — CHECK constraint in 001, copied
 * verbatim into app_metadata by sync_user_role_to_auth), so compare
 * case-insensitively rather than against one casing.
 */
export function isStudent(user: MinimalUser): boolean {
  const role = user?.app_metadata?.role;
  return typeof role === "string" && role.toUpperCase() === "STUDENT";
}
