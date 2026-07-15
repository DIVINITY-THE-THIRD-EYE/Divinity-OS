"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { formErrorMessage } from "@/lib/form-error";

export default function LoginForm({
  next,
  initialError,
}: {
  next: string;
  initialError?: string;
}) {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(initialError ?? "");

  // The form instance survives the /login → /portal → /login middleware
  // bounce (same route segment, React reconciles), so useState's initializer
  // never re-runs — a fresh server error (e.g. not-student) must be synced in.
  useEffect(() => {
    if (initialError) setError(initialError);
  }, [initialError]);

  async function signIn(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setBusy(true);
    try {
      const supabase = createClient();
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      if (signInError) throw new Error(signInError.message);
      router.push(next);
      router.refresh();
    } catch (err) {
      setError(formErrorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  const field =
    "w-full border-b border-[var(--line)] bg-transparent py-3 font-body text-fg placeholder:text-fg-muted/60 focus:border-accent focus:outline-none";

  return (
    <div className="mx-auto max-w-sm">
      <form onSubmit={signIn} className="space-y-6" aria-label="Student login">
        <div>
          <label htmlFor="login-email" className="eyebrow mb-2 block text-fg-muted">
            Email address
          </label>
          <input
            id="login-email"
            name="email"
            type="email"
            inputMode="email"
            autoComplete="email"
            required
            aria-required="true"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            className={field}
          />
        </div>
        <div>
          <label htmlFor="login-password" className="eyebrow mb-2 block text-fg-muted">
            Password
          </label>
          <input
            id="login-password"
            name="password"
            type="password"
            autoComplete="current-password"
            required
            aria-required="true"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            className={field}
          />
        </div>
        {error && (
          <p role="alert" className="font-mono text-[12px] text-clay">
            {error}
          </p>
        )}
        <button
          type="submit"
          disabled={busy}
          className="w-full bg-accent py-4 font-mono text-[11px] uppercase tracking-wide text-surface transition-colors hover:bg-ember-pale disabled:opacity-60"
        >
          {busy ? "Signing in…" : "Sign in"}
        </button>
      </form>
    </div>
  );
}
