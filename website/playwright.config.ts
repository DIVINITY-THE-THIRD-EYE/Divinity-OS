import { defineConfig, devices } from "@playwright/test";

/**
 * Playwright E2E config for the Divinity marketing site.
 *
 * Runs against a real production build (`next build && next start`) so the tests
 * exercise the same output that ships. Unit tests (vitest) stay separate — they
 * only match `lib/**\/*.test.ts`; these E2E specs live in `e2e/` as `*.spec.ts`.
 */
export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? "github" : "list",
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
  },
  // Visual regression (17_TESTING.md): 2% pixel-diff tolerance across the
  // 4 named pages' baselines (e2e/visual.spec.ts).
  expect: {
    toHaveScreenshot: { maxDiffPixelRatio: 0.02 },
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
  ],
  webServer: {
    command: "npm run build && npm run start",
    url: "http://localhost:3000",
    timeout: 180_000,
    reuseExistingServer: !process.env.CI,
  },
});
