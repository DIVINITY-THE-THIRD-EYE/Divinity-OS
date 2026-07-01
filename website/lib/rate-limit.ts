// Lightweight in-memory fixed-window rate limiter.
// Suitable for a single-instance / low-traffic marketing site. For multi-region
// serverless, swap the Map for Upstash Redis (same interface).

type Bucket = { count: number; resetAt: number };

const store = new Map<string, Bucket>();

export type RateLimitResult = {
  ok: boolean;
  remaining: number;
  resetAt: number;
  retryAfter: number; // seconds
};

/**
 * @param key      unique identifier (e.g. `contact:<ip>`)
 * @param limit    max requests per window
 * @param windowMs window length in milliseconds
 */
export function rateLimit(key: string, limit = 5, windowMs = 60_000): RateLimitResult {
  const now = Date.now();
  const existing = store.get(key);

  if (!existing || existing.resetAt <= now) {
    const resetAt = now + windowMs;
    store.set(key, { count: 1, resetAt });
    return { ok: true, remaining: limit - 1, resetAt, retryAfter: 0 };
  }

  existing.count += 1;
  const ok = existing.count <= limit;
  return {
    ok,
    remaining: Math.max(0, limit - existing.count),
    resetAt: existing.resetAt,
    retryAfter: ok ? 0 : Math.ceil((existing.resetAt - now) / 1000),
  };
}

/** Best-effort client IP from forwarded headers (Vercel/proxies). */
export function clientIp(req: Request): string {
  const xff = req.headers.get("x-forwarded-for");
  if (xff) return xff.split(",")[0].trim();
  return req.headers.get("x-real-ip") || "unknown";
}

/** Opportunistically drop expired buckets so the Map can't grow unbounded. */
export function sweep(): void {
  const now = Date.now();
  for (const [k, v] of store) if (v.resetAt <= now) store.delete(k);
}
