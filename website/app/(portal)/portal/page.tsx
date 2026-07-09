import type { Metadata } from "next";
import type { User } from "@supabase/supabase-js";
import { redirect } from "next/navigation";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import { createClient } from "@/lib/supabase/server";
import { isStudent } from "@/lib/supabase/role-gate";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Student Portal",
    description: `Your ${site.full} student dashboard.`,
    path: "/portal",
    noindex: true,
  });
}

// Defense-in-depth: middleware.ts already guards every /portal/** request
// (unauthenticated → /login, non-student → signed out + /login). This
// server-side re-check is the "layout reads session via server client"
// requirement from 12_STUDENT_LOGIN.md — done here rather than in a shared
// (portal) layout, since /login and /logout live in the same route group
// and must NOT redirect to themselves.
export default async function PortalPage() {
  // Fail closed: if Supabase isn't configured yet (missing env) or the auth
  // check itself errors, treat it exactly like "no session" — redirect to
  // /login rather than throwing a raw error to the visitor. No session
  // verified is the correct default-deny outcome either way.
  let user: User | null = null;
  try {
    const supabase = await createClient();
    const res = await supabase.auth.getUser();
    user = res.data.user;
  } catch {
    user = null;
  }

  if (!user || !isStudent(user)) {
    redirect("/login");
  }

  const displayName = user.user_metadata?.full_name || user.phone || "Student";

  return (
    <section className="px-6 py-24 md:px-10 md:py-32">
      <div className="mx-auto max-w-3xl">
        <p className="eyebrow mb-4 text-accent">Student portal</p>
        <h1 className="font-display text-[clamp(32px,5vw,56px)] font-light leading-tight text-fg">
          Welcome, {displayName}.
        </h1>
        <p className="mt-4 max-w-lg font-body text-[15px] leading-relaxed text-fg-muted">
          Your classes, schedule and progress live in the Divinity app — the same
          account, right here on the web.
        </p>

        {/* Flutter Web slot — filled by 13_FLUTTER_WEB.md */}
        <div className="mt-12 border border-[var(--line)] p-10 text-center font-body text-[14px] text-fg-muted">
          Your dashboard is on its way here.
        </div>

        <a
          href="/logout"
          className="mt-10 inline-block font-mono text-[11px] uppercase tracking-wide text-fg-muted transition-colors hover:text-accent"
        >
          Sign out
        </a>
      </div>
    </section>
  );
}
