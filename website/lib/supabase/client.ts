import { createBrowserClient } from "@supabase/ssr";

/**
 * Browser Supabase client — anon key only (public by design). Session is
 * persisted via cookies (not localStorage) so the server client below can
 * read the same session during SSR/middleware. Never import this from a
 * server component.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
