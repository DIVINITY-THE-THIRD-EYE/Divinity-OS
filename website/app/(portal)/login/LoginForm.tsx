"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { isE164Phone } from "@/lib/validation";
import { formErrorMessage } from "@/lib/form-error";

type Step = "phone" | "otp";

export default function LoginForm({
  next,
  initialError,
}: {
  next: string;
  initialError?: string;
}) {
  const router = useRouter();
  const [step, setStep] = useState<Step>("phone");
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(initialError ?? "");

  async function sendCode(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    if (!isE164Phone(phone)) {
      setError("Enter your phone number in international format, e.g. +919214652400.");
      return;
    }
    setBusy(true);
    try {
      const supabase = createClient();
      const { error: otpError } = await supabase.auth.signInWithOtp({ phone });
      if (otpError) throw new Error(otpError.message);
      setStep("otp");
    } catch (err) {
      setError(formErrorMessage(err));
    } finally {
      setBusy(false);
    }
  }

  async function verifyCode(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setBusy(true);
    try {
      const supabase = createClient();
      const { error: verifyError } = await supabase.auth.verifyOtp({
        phone,
        token: code,
        type: "sms",
      });
      if (verifyError) throw new Error(verifyError.message);
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
      {step === "phone" ? (
        <form onSubmit={sendCode} className="space-y-6" aria-label="Student login — phone">
          <div>
            <label htmlFor="login-phone" className="eyebrow mb-2 block text-fg-muted">
              Phone number
            </label>
            <input
              id="login-phone"
              name="phone"
              type="tel"
              inputMode="tel"
              autoComplete="tel"
              required
              aria-required="true"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="+919214652400"
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
            {busy ? "Sending code…" : "Send code"}
          </button>
        </form>
      ) : (
        <form onSubmit={verifyCode} className="space-y-6" aria-label="Student login — verification code">
          <p className="font-body text-[13px] text-fg-muted">
            We sent a code to {phone}.{" "}
            <button
              type="button"
              onClick={() => {
                setStep("phone");
                setError("");
              }}
              className="text-accent underline underline-offset-4 hover:no-underline"
            >
              Change number
            </button>
          </p>
          <div>
            <label htmlFor="login-code" className="eyebrow mb-2 block text-fg-muted">
              Verification code
            </label>
            <input
              id="login-code"
              name="code"
              type="text"
              inputMode="numeric"
              autoComplete="one-time-code"
              required
              aria-required="true"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder="123456"
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
            {busy ? "Verifying…" : "Verify & sign in"}
          </button>
        </form>
      )}
    </div>
  );
}
