// Role comes from the JWT's app_metadata.role (synced by the DB's
// sync_user_role_to_auth trigger) — trust the claim, never re-derive it with
// a client-side database read (SECURITY NOTES, 12_STUDENT_LOGIN.md).
export type AppRole = "student" | "trainer" | "admin";

type MinimalUser = {
  app_metadata?: Record<string, unknown> | null;
} | null | undefined;

/** True only when the signed-in user's JWT role claim is exactly "student". */
export function isStudent(user: MinimalUser): boolean {
  return user?.app_metadata?.role === "student";
}
