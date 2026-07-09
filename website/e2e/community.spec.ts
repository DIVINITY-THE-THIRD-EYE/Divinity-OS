import { test, expect } from "@playwright/test";

test.describe("10 community pages", () => {
  const routes = ["/events", "/gallery", "/testimonials", "/faq", "/blog"];

  for (const path of routes) {
    test(`${path} has an h1 and no console errors`, async ({ page }) => {
      const errors: string[] = [];
      page.on("console", (msg) => {
        if (msg.type() === "error") errors.push(msg.text());
      });
      await page.goto(path);
      await expect(page.locator("h1")).toBeVisible();
      expect(errors, errors.join("\n")).toHaveLength(0);
    });
  }

  test.describe("mobile widths — no overflow", () => {
    test.use({ viewport: { width: 375, height: 812 } });
    for (const path of routes) {
      test(`${path} at 375px`, async ({ page }) => {
        await page.goto(path);
        const overflow = await page.evaluate(() => document.body.scrollWidth > window.innerWidth);
        expect(overflow).toBe(false);
      });
    }
  });

  test("blog/events/testimonials are noindex (BD-003 — staging content, not real yet)", async ({ page }) => {
    for (const path of ["/blog", "/events", "/testimonials"]) {
      await page.goto(path);
      const robots = await page.locator('meta[name="robots"]').getAttribute("content");
      expect(robots, `${path} robots meta`).toContain("noindex");
    }
  });

  test("faq and gallery are indexable (real content)", async ({ page }) => {
    for (const path of ["/faq", "/gallery"]) {
      await page.goto(path);
      const robots = await page.locator('meta[name="robots"]').count();
      // No robots meta at all means default (indexable) — Next.js only
      // renders the tag when noindex/nofollow is explicitly set.
      expect(robots, `${path} should have no noindex meta`).toBe(0);
    }
  });

  test("testimonials shows the invite-to-share empty state, not staged quotes", async ({ page }) => {
    await page.goto("/testimonials");
    await expect(page.getByText(/coming soon/i)).toBeVisible();
    await expect(page.getByText(/STAGING/i)).toHaveCount(0);
    await expect(page.getByRole("link", { name: /share your story/i })).toHaveAttribute("href", /wa\.me/);
  });

  test("faq page has FAQPage JSON-LD", async ({ page }) => {
    await page.goto("/faq");
    const scripts = await page.locator('script[type="application/ld+json"]').allTextContents();
    expect(scripts.some((s) => s.includes("FAQPage"))).toBe(true);
  });
});
