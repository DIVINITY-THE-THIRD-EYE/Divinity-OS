import { NextResponse } from "next/server";

// Public certificate verification — graceful-fallback by design (same ethos as
// the contact/subscribe routes). The marketing site intentionally has NO direct
// Supabase coupling; if you want LIVE verification, expose a *public, PII-safe*
// read endpoint (a Supabase RPC / edge function that returns only
// {valid, holder, programme, issuedOn}) and set its URL in CERT_VERIFY_ENDPOINT.
// Until then this returns a helpful "verify with the academy" response so the
// page works with zero configuration.

const CODE_RE = /^DIV-[A-Z0-9]{4}-[A-Z0-9]{4}$/; // e.g. DIV-7K2A-9QF3

export async function POST(req: Request) {
  let code = "";
  try {
    const body = await req.json();
    code = String(body?.code ?? "").trim().toUpperCase();
  } catch {
    return NextResponse.json({ status: "error", message: "Invalid request." }, { status: 400 });
  }

  if (!CODE_RE.test(code)) {
    return NextResponse.json(
      {
        status: "invalid_format",
        message: "That doesn't look like a Divinity certificate code (format: DIV-XXXX-XXXX).",
      },
      { status: 200 },
    );
  }

  const endpoint = process.env.CERT_VERIFY_ENDPOINT;
  if (!endpoint) {
    // Zero-config fallback: no live lookup wired up yet.
    return NextResponse.json(
      {
        status: "unavailable",
        code,
        message:
          "Online verification isn't enabled yet. To confirm this certificate, contact the academy with the code above.",
      },
      { status: 200 },
    );
  }

  try {
    const res = await fetch(`${endpoint}?code=${encodeURIComponent(code)}`, {
      headers: { accept: "application/json" },
      // never cache a verification result
      cache: "no-store",
    });
    if (!res.ok) throw new Error(`upstream ${res.status}`);
    const data = await res.json();
    // Expected upstream shape: { valid: boolean, holder, programme, issuedOn }
    return NextResponse.json({ status: data?.valid ? "valid" : "not_found", code, ...data });
  } catch {
    return NextResponse.json(
      { status: "error", code, message: "Verification service is temporarily unavailable. Please try again later." },
      { status: 502 },
    );
  }
}
