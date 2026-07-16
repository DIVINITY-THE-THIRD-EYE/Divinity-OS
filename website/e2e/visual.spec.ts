import { test, expect } from "@playwright/test";

/**
 * 17_TESTING.md visual regression: home (both themes, desktop+mobile),
 * pricing, programs, contact. Reduced motion is emulated everywhere so
 * screenshots capture the settled DOM, not an arbitrary animation frame —
 * without it these would be inherently flaky (RULES: "a flaky test is a
 * bug, never retry-mask it").
 *
 * Baselines were generated on this machine (Windows), not the CI runner —
 * cross-OS font/subpixel rendering differences mean the FIRST CI run is
 * expected to need `npx playwright test e2e/visual.spec.ts --update-snapshots`
 * committed once from within CI (standard practice for Playwright visual
 * regression; see STATUS.md 17_TESTING.md entry for why this couldn't be
 * done from this environment).
 */
async function setTheme(page: import("@playwright/test").Page, theme: "light" | "dark") {
  await page.addInitScript((t) => window.localStorage.setItem("divinity_theme", t), theme);
}

// Full-page screenshots need every image fully loaded first, or a real
// flake results (caught directly: a founder photo sometimes hadn't
// finished decoding by the time the shot was taken). next/image's
// `loading="lazy"` only fetches once IntersectionObserver reports a real
// intersection — a scrollTo jump doesn't reliably trigger this for every
// layout, so instead force every image eager (the browser then requests
// all of them the instant they're assigned, independent of scroll position
// or container layout) and wait for `.complete`. Some source photos are
// large (public/studio/*.webp — see 15_PERFORMANCE.md's image audit) and
// this environment has no `sharp`, so resize falls back to a slower WASM
// path (~1-3s/image, confirmed via direct curl) — a modest timeout margin
// covers that without masking a genuine hang.
async function gotoAndSettle(page: import("@playwright/test").Page, path: string) {
  await page.goto(path);
  await page.waitForLoadState("networkidle");
  await page.evaluate(() => {
    document.querySelectorAll("img[loading='lazy']").forEach((img) => {
      (img as HTMLImageElement).loading = "eager";
    });
  });
  await page.waitForFunction(() => Array.from(document.images).every((img) => img.complete), null, {
    timeout: 30_000,
  });
  await page.waitForTimeout(300);
}

test.describe("17 visual regression", () => {
  test.use({ colorScheme: "dark" });
  test.setTimeout(45_000); // slow on-demand image resize without `sharp` — see gotoAndSettle

  for (const theme of ["dark", "light"] as const) {
    for (const viewport of ["desktop", "mobile"] as const) {
      test(`home (${theme}, ${viewport})`, async ({ page }) => {
        await page.setViewportSize(
          viewport === "desktop" ? { width: 1280, height: 900 } : { width: 375, height: 812 }
        );
        await page.emulateMedia({ reducedMotion: "reduce" });
        await setTheme(page, theme);
        await gotoAndSettle(page, "/");
        await expect(page).toHaveScreenshot(`home-${theme}-${viewport}.png`, { fullPage: true });
      });
    }
  }

  for (const path of ["/pricing", "/programs", "/contact"]) {
    test(`${path} (dark, desktop)`, async ({ page }) => {
      await page.setViewportSize({ width: 1280, height: 900 });
      await page.emulateMedia({ reducedMotion: "reduce" });
      await setTheme(page, "dark");
      await gotoAndSettle(page, path);
      await expect(page).toHaveScreenshot(`${path.slice(1)}-dark-desktop.png`, { fullPage: true });
    });
  }
});
