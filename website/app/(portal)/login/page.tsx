import type { Metadata } from "next";
import { pageMeta } from "@/lib/seo";
import { fetchSiteSettings } from "@/lib/content";
import LoginForm from "./LoginForm";

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return pageMeta({
    title: "Student Login",
    description: `Sign in to your ${site.full} student account.`,
    path: "/login",
    noindex: true,
  });
}

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ next?: string; error?: string }>;
}) {
  const params = await searchParams;
  const next = params.next && params.next.startsWith("/") ? params.next : "/portal";
  const initialError =
    params.error === "not-student"
      ? "This portal is for students. Trainers and admins use the mobile app."
      : undefined;

  return (
    <section className="px-6 py-24 md:px-10 md:py-32">
      <div className="mx-auto max-w-sm text-center">
        <p className="eyebrow mb-4 text-accent">Student login</p>
        <h1 className="font-display text-[clamp(32px,5vw,56px)] font-light leading-tight text-fg">
          Welcome back.
        </h1>
        <p className="mt-4 font-body text-[15px] text-fg-muted">
          Sign in with the same phone number you use in the Divinity app.
        </p>
      </div>
      <div className="mt-12">
        <LoginForm next={next} initialError={initialError} />
      </div>
    </section>
  );
}
