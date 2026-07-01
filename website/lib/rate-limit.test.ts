import { describe, it, expect } from "vitest";
import { rateLimit, clientIp } from "./rate-limit";

describe("rateLimit", () => {
  it("allows requests up to the limit, then blocks", () => {
    const key = `t-${Math.random()}`;
    const limit = 3;
    const results = Array.from({ length: 4 }, () => rateLimit(key, limit, 60_000));
    expect(results.slice(0, 3).every((r) => r.ok)).toBe(true);
    expect(results[3].ok).toBe(false);
    expect(results[3].retryAfter).toBeGreaterThan(0);
  });

  it("decrements remaining correctly", () => {
    const key = `t-${Math.random()}`;
    expect(rateLimit(key, 5, 60_000).remaining).toBe(4);
    expect(rateLimit(key, 5, 60_000).remaining).toBe(3);
  });

  it("resets after the window elapses", async () => {
    const key = `t-${Math.random()}`;
    const windowMs = 8;
    expect(rateLimit(key, 1, windowMs).ok).toBe(true); // first allowed
    expect(rateLimit(key, 1, windowMs).ok).toBe(false); // second blocked in-window
    await new Promise((r) => setTimeout(r, windowMs + 5));
    expect(rateLimit(key, 1, windowMs).ok).toBe(true); // fresh window allows again
  });

  it("isolates separate keys", () => {
    const a = `a-${Math.random()}`;
    const b = `b-${Math.random()}`;
    rateLimit(a, 1, 60_000);
    expect(rateLimit(a, 1, 60_000).ok).toBe(false);
    expect(rateLimit(b, 1, 60_000).ok).toBe(true);
  });
});

describe("clientIp", () => {
  it("reads the first x-forwarded-for entry", () => {
    const req = new Request("http://x", { headers: { "x-forwarded-for": "1.2.3.4, 5.6.7.8" } });
    expect(clientIp(req)).toBe("1.2.3.4");
  });

  it("falls back to x-real-ip then 'unknown'", () => {
    expect(clientIp(new Request("http://x", { headers: { "x-real-ip": "9.9.9.9" } }))).toBe("9.9.9.9");
    expect(clientIp(new Request("http://x"))).toBe("unknown");
  });
});
