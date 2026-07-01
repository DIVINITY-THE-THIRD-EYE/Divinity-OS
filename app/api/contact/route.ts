import { NextResponse } from "next/server";
import { rateLimit, clientIp, sweep } from "@/lib/rate-limit";
import { isEmail, asString, isPlainObject, declaredBodyTooLarge } from "@/lib/validation";

export const runtime = "nodejs";

export async function POST(req: Request) {
  // Rate limit: 5 enquiries / minute / IP.
  sweep();
  const limit = rateLimit(`contact:${clientIp(req)}`, 5, 60_000);
  if (!limit.ok) {
    return NextResponse.json(
      { error: "Too many requests. Please wait a moment and try again." },
      { status: 429, headers: { "Retry-After": String(limit.retryAfter) } }
    );
  }

  // Reject oversized bodies before buffering the stream into memory.
  if (declaredBodyTooLarge(req)) {
    return NextResponse.json({ error: "That request is too large." }, { status: 413 });
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid request." }, { status: 400 });
  }

  // Reject null / array / primitive bodies before reading fields.
  if (!isPlainObject(body)) {
    return NextResponse.json({ error: "Invalid request." }, { status: 400 });
  }

  // Honeypot tripped → pretend success, drop silently.
  if (asString(body.company).trim() !== "") {
    return NextResponse.json({ ok: true, delivered: false });
  }

  const name = asString(body.name).trim();
  const email = asString(body.email).trim();
  const intention = asString(body.intention).trim();
  const message = asString(body.message).trim();

  // Length guards — reject absurd payloads before any downstream call.
  if (name.length > 120 || email.length > 200 || message.length > 4000) {
    return NextResponse.json({ error: "That request is too large." }, { status: 413 });
  }

  const VALID_INTENTIONS = [
    "Yoga", "Fitness", "Therapeutic yoga",
    "Pranayama & meditation", "Diet & lifestyle", "Not sure yet", ""
  ];
  if (intention && !VALID_INTENTIONS.includes(intention)) {
    return NextResponse.json({ error: "Invalid selection." }, { status: 422 });
  }

  if (!name || !isEmail(email)) {
    return NextResponse.json(
      { error: "Please add your name and a valid email." },
      { status: 422 }
    );
  }

  const apiKey = process.env.BREVO_API_KEY;

  // Graceful fallback: with no key configured, accept the enquiry so the UI
  // works in development. Wire BREVO_API_KEY to actually deliver email.
  if (!apiKey) {
    console.info("[contact] Brevo not configured — enquiry received:", {
      name,
      email,
      intention,
    });
    return NextResponse.json({ ok: true, delivered: false });
  }

  const toEmail = process.env.BREVO_TO_EMAIL || "hello@staging.divinitytte.com";
  const toName = process.env.BREVO_TO_NAME || "Divinity (Staging)";
  const fromEmail = process.env.BREVO_FROM_EMAIL || "no-reply@staging.divinitytte.com";
  const fromName = process.env.BREVO_FROM_NAME || "Divinity Website (Staging)";

  const safeName = name.replace(/[^\p{L}\p{N}\s.\-']/gu, '').slice(0, 80);

  const html = `
    <h2>New enquiry — Divinity</h2>
    <p><strong>Name:</strong> ${escapeHtml(name)}</p>
    <p><strong>Email:</strong> ${escapeHtml(email)}</p>
    <p><strong>Interested in:</strong> ${escapeHtml(intention) || "—"}</p>
    <p><strong>Message:</strong><br/>${escapeHtml(message) || "—"}</p>
  `;

  try {
    const res = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": apiKey,
        "Content-Type": "application/json",
        accept: "application/json",
      },
      body: JSON.stringify({
        sender: { email: fromEmail, name: fromName },
        to: [{ email: toEmail, name: toName }],
        replyTo: { email, name: safeName },
        subject: `New enquiry from ${safeName}`,
        htmlContent: html,
      }),
      // Don't let a slow/hung Brevo keep the request open.
      signal: AbortSignal.timeout(8000),
    });

    if (!res.ok) {
      const detail = await res.text().catch(() => "");
      console.error("[contact] Brevo error", res.status, detail);
      return NextResponse.json(
        { error: "We couldn't send that just now. Please try again." },
        { status: 502 }
      );
    }

    return NextResponse.json({ ok: true, delivered: true });
  } catch (err) {
    console.error("[contact] network error", err);
    return NextResponse.json(
      { error: "We couldn't send that just now. Please try again." },
      { status: 502 }
    );
  }
}

function escapeHtml(s: string) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
