/** @type {import('next').NextConfig} */
const isProd = process.env.NODE_ENV === "production";

// Content-Security-Policy. `'unsafe-inline'` is required for Next's hydration
// bootstrap, the inline JSON-LD, and framer-motion's injected inline styles, so
// this is defense-in-depth (frame-ancestors / base-uri / form-action / scoped
// connect+img+font) rather than a nonce-strict lockdown. Applied in production
// only so it never interferes with the dev server's eval-based HMR.
const csp = [
  "default-src 'self'",
  "base-uri 'self'",
  "form-action 'self'",
  "frame-ancestors 'self'",
  "object-src 'none'",
  "img-src 'self' data: blob: https://cdn.sanity.io",
  "font-src 'self'",
  "style-src 'self' 'unsafe-inline'",
  "script-src 'self' 'unsafe-inline'",
  "connect-src 'self' https://api.brevo.com",
].join("; ");

const securityHeaders = [
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "X-Frame-Options", value: "SAMEORIGIN" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "X-DNS-Prefetch-Control", value: "on" },
  {
    key: "Permissions-Policy",
    value: "camera=(), microphone=(), geolocation=(), browsing-topics=()",
  },
  {
    key: "Strict-Transport-Security",
    value: "max-age=63072000; includeSubDomains; preload",
  },
  ...(isProd ? [{ key: "Content-Security-Policy", value: csp }] : []),
];

const nextConfig = {
  // ESLint is now configured (.eslintrc.json) and runs in CI/build.
  poweredByHeader: false, // don't advertise the framework
  images: {
    formats: ["image/avif", "image/webp"],
    // Static photography — cache optimized variants for a day instead of the
    // 60s default, cutting revalidation round-trips (short enough that a
    // pre-launch asset swap still propagates within a day).
    minimumCacheTTL: 86400,
    remotePatterns: [{ protocol: "https", hostname: "cdn.sanity.io" }],
  },
  async headers() {
    return [{ source: "/:path*", headers: securityHeaders }];
  },
};

export default nextConfig;
