import { createServerClient } from "@supabase/ssr";
import type { User } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
import { isStudent } from "@/lib/supabase/role-gate";

/**
 * Runs on every non-static request: refreshes the Supabase session cookie
 * (so it never silently expires mid-visit), then guards /portal/**.
 * Unauthenticated → /login. Authenticated but not a student (trainer/admin
 * use the mobile app, per D003) → sign out + /login with a message.
 */
export async function middleware(request: NextRequest) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  // Missing Supabase env (e.g. an environment without the owner's real
  // values yet) must never take down every route — this matcher runs on
  // almost the whole site. Skip auth entirely rather than throw; /portal's
  // own server client still throws when actually visited, a contained
  // failure instead of a site-wide 500 from middleware.
  if (!supabaseUrl || !supabaseAnonKey) {
    return NextResponse.next();
  }

  let response = NextResponse.next({ request });

  const supabase = createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options)
        );
      },
    },
  });

  // Fail closed: a thrown/network error while checking auth is treated the
  // same as "no user" for the /portal gate below, rather than crashing
  // middleware for every route on the site.
  let user: User | null = null;
  try {
    const res = await supabase.auth.getUser();
    user = res.data.user;
  } catch {
    user = null;
  }

  if (request.nextUrl.pathname.startsWith("/portal")) {
    if (!user) {
      const url = request.nextUrl.clone();
      url.pathname = "/login";
      url.searchParams.set("next", request.nextUrl.pathname);
      return NextResponse.redirect(url);
    }
    if (!isStudent(user)) {
      await supabase.auth.signOut();
      const url = request.nextUrl.clone();
      url.pathname = "/login";
      url.searchParams.set("error", "not-student");
      return NextResponse.redirect(url);
    }
  }

  return response;
}

export const config = {
  matcher: [
    /*
     * Run on every request except static assets/images/Next internals — those
     * never need a session refresh or the /portal guard.
     */
    "/((?!_next/static|_next/image|favicon.ico|icon.png|apple-icon.png|.*\\.(?:svg|png|jpg|jpeg|gif|webp|avif)$).*)",
  ],
};
