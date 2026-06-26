import { NextResponse } from "next/server";

export const runtime = "nodejs";

type Body = {
  name?: string;
  email?: string;
  intention?: string;
  message?: string;
};

const isEmail = (v: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);

export async function POST(req: Request) {
  let body: Body;
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid request." }, { status: 400 });
  }

  const name = (body.name || "").trim();
  const email = (body.email || "").trim();
  const intention = (body.intention || "").trim();
  const message = (body.message || "").trim();

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

  const toEmail = process.env.BREVO_TO_EMAIL || "hello@divinity.example";
  const toName = process.env.BREVO_TO_NAME || "Divinity";
  const fromEmail = process.env.BREVO_FROM_EMAIL || "no-reply@divinity.example";
  const fromName = process.env.BREVO_FROM_NAME || "Divinity Website";

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
        replyTo: { email, name },
        subject: `New enquiry from ${name}`,
        htmlContent: html,
      }),
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
