"use client";

import { useState } from "react";

type Result = {
  status: string;
  code?: string;
  message?: string;
  holder?: string;
  programme?: string;
  issuedOn?: string;
};

const TONE: Record<string, string> = {
  valid: "border-accent text-fg",
  unavailable: "border-[var(--line)] text-fg-muted",
  invalid_format: "border-[var(--line)] text-fg-muted",
  not_found: "border-[var(--line)] text-fg-muted",
  error: "border-[var(--line)] text-fg-muted",
};

export default function VerifyForm() {
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Result | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!code.trim()) return;
    setLoading(true);
    setResult(null);
    try {
      const res = await fetch("/api/verify-certificate", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ code }),
      });
      setResult(await res.json());
    } catch {
      setResult({ status: "error", message: "Could not reach the verification service. Please try again." });
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-md">
      <form onSubmit={onSubmit} className="flex flex-col gap-3 sm:flex-row">
        <label htmlFor="cert-code" className="sr-only">
          Certificate code
        </label>
        <input
          id="cert-code"
          name="code"
          value={code}
          onChange={(e) => setCode(e.target.value)}
          placeholder="DIV-XXXX-XXXX"
          autoComplete="off"
          spellCheck={false}
          className="flex-1 rounded-none border border-[var(--line)] bg-deep px-4 py-3 font-mono text-sm uppercase tracking-wide text-fg placeholder:text-fg-muted/60 focus:border-accent focus:outline-none"
        />
        <button
          type="submit"
          disabled={loading}
          className="border border-accent bg-accent px-6 py-3 font-mono text-xs uppercase tracking-wide text-surface transition hover:bg-transparent hover:text-accent disabled:opacity-50"
        >
          {loading ? "Checking…" : "Verify"}
        </button>
      </form>

      {result && (
        <div
          role="status"
          aria-live="polite"
          className={`mt-6 border px-5 py-4 ${TONE[result.status] ?? TONE.error}`}
        >
          {result.status === "valid" ? (
            <>
              <p className="font-display text-lg text-accent">Authentic certificate ✓</p>
              <dl className="mt-3 space-y-1 font-body text-sm text-fg-muted">
                {result.holder && (
                  <div>
                    <dt className="inline font-mono text-[11px] uppercase tracking-wide text-fg-muted/70">Holder: </dt>
                    <dd className="inline text-fg">{result.holder}</dd>
                  </div>
                )}
                {result.programme && (
                  <div>
                    <dt className="inline font-mono text-[11px] uppercase tracking-wide text-fg-muted/70">Programme: </dt>
                    <dd className="inline text-fg">{result.programme}</dd>
                  </div>
                )}
                {result.issuedOn && (
                  <div>
                    <dt className="inline font-mono text-[11px] uppercase tracking-wide text-fg-muted/70">Issued: </dt>
                    <dd className="inline text-fg">{result.issuedOn}</dd>
                  </div>
                )}
              </dl>
            </>
          ) : (
            <p className="font-body text-sm leading-relaxed">
              {result.message ?? "We couldn't verify that code."}
            </p>
          )}
        </div>
      )}
    </div>
  );
}
