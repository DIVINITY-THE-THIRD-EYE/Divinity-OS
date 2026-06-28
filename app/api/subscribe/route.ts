import { NextResponse } from "next/server";
import { rateLimit, clientIp, sweep } from "@/lib/rate-limit";
import { isEmail } from "@/lib/validation";

export const runtime = "nodejs";

export async function POST(req: Request) {
  // Rate limit: 5 subscribes / minute / IP.
  sweep();
  const limit = rateLimit(`subscribe:${clientIp(req)}`, 5, 60_000);
  if (!limit.ok) {
    return NextResponse.json(
      { error: "Too many requests. Please wait a moment and try again." },
      { status: 429, headers: { "Retry-After": String(limit.retryAfter) } }
    );
  }

  let body: { email?: string; company?: string };
  try {
    body = await req.json();
  } catch {
    return NextResponse.json({ error: "Invalid request." }, { status: 400 });
  }

  // Honeypot tripped → pretend success, drop silently.
  if ((body.company || "").trim() !== "") {
    return NextResponse.json({ ok: true, delivered: false });
  }

  const email = (body.email || "").trim();
  if (email.length > 200 || !isEmail(email)) {
    return NextResponse.json({ error: "Please enter a valid email." }, { status: 422 });
  }

  const apiKey = process.env.BREVO_API_KEY;
  const listId = process.env.BREVO_LIST_ID ? Number(process.env.BREVO_LIST_ID) : undefined;

  if (!apiKey) {
    console.info("[subscribe] Brevo not configured — subscriber:", email);
    return NextResponse.json({ ok: true, delivered: false });
  }

  try {
    const res = await fetch("https://api.brevo.com/v3/contacts", {
      method: "POST",
      headers: {
        "api-key": apiKey,
        "Content-Type": "application/json",
        accept: "application/json",
      },
      body: JSON.stringify({
        email,
        updateEnabled: true,
        ...(listId ? { listIds: [listId] } : {}),
      }),
    });

    if (!res.ok) {
      const detail = await res.text().catch(() => "");
      console.error("[subscribe] Brevo error", res.status, detail);
      return NextResponse.json({ error: "Could not subscribe. Please try again." }, { status: 502 });
    }

    return NextResponse.json({ ok: true, delivered: true });
  } catch (err) {
    console.error("[subscribe] network error", err);
    return NextResponse.json({ error: "Could not subscribe. Please try again." }, { status: 502 });
  }
}
