import { describe, it, expect } from "vitest";
import { POST as contactPOST } from "@/app/api/contact/route";
import { POST as subscribePOST } from "@/app/api/subscribe/route";

function makeReq(url: string, body: unknown, ip = "t-" + Math.random()) {
  return new Request(url, {
    method: "POST",
    headers: { "content-type": "application/json", "x-forwarded-for": ip },
    body: typeof body === "string" ? body : JSON.stringify(body),
  });
}

const contact = (body: unknown, ip?: string) =>
  contactPOST(makeReq("http://localhost/api/contact", body, ip));
const subscribe = (body: unknown, ip?: string) =>
  subscribePOST(makeReq("http://localhost/api/subscribe", body, ip));

describe("POST /api/contact", () => {
  it("accepts a valid enquiry (no key → delivered:false)", async () => {
    const res = await contact({ name: "Asha", email: "asha@example.com", intention: "Yoga" });
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, delivered: false });
  });

  it("silently drops honeypot submissions", async () => {
    const res = await contact({ name: "Bot", email: "b@e.com", company: "Acme" });
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, delivered: false });
  });

  it("rejects an invalid email with 422", async () => {
    expect((await contact({ name: "X", email: "nope" })).status).toBe(422);
  });

  it("rejects malformed JSON with 400", async () => {
    expect((await contact("{not json")).status).toBe(400);
  });

  it("rejects oversized payloads with 413", async () => {
    const res = await contact({ name: "X", email: "x@e.com", message: "a".repeat(5000) });
    expect(res.status).toBe(413);
  });

  it("rate-limits after 5 requests from one IP", async () => {
    const ip = "contact-rl";
    const codes: number[] = [];
    for (let i = 0; i < 6; i++) codes.push((await contact({ name: "X", email: "x@e.com" }, ip)).status);
    expect(codes.slice(0, 5).every((c) => c === 200)).toBe(true);
    expect(codes[5]).toBe(429);
  });
});

describe("POST /api/subscribe", () => {
  it("accepts a valid email (no key → delivered:false)", async () => {
    const res = await subscribe({ email: "asha@example.com" });
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, delivered: false });
  });

  it("silently drops honeypot submissions", async () => {
    expect((await subscribe({ email: "b@e.com", company: "Acme" })).status).toBe(200);
  });

  it("rejects an invalid email with 422", async () => {
    expect((await subscribe({ email: "nope" })).status).toBe(422);
  });

  it("rate-limits after 5 requests from one IP", async () => {
    const ip = "subscribe-rl";
    const codes: number[] = [];
    for (let i = 0; i < 6; i++) codes.push((await subscribe({ email: "x@e.com" }, ip)).status);
    expect(codes.slice(0, 5).every((c) => c === 200)).toBe(true);
    expect(codes[5]).toBe(429);
  });
});
