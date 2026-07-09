import { test, expect } from "@playwright/test";

test.describe("09 commerce pages", () => {
  test("pricing shows at least one plan", async ({ page }) => {
    await page.goto("/pricing");
    await expect(page.locator("h1")).toBeVisible();
    // Membership section renders at least one plan name/price pairing
    // (cadence displays as "/ quarter" — "per " is stripped, see Membership.tsx).
    await expect(page.getByText(/\/\s*(month|quarter|year|class)/i).first()).toBeVisible();
  });

  test("membership page renders and links back to pricing", async ({ page }) => {
    await page.goto("/membership");
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.getByRole("link", { name: /see all plans/i })).toBeVisible();
  });

  test("schedule's per-row Join link builds a wa.me URL with the batch label", async ({ page }) => {
    await page.goto("/schedule");
    const joinLink = page.getByRole("link", { name: /^join/i }).first();
    await joinLink.scrollIntoViewIfNeeded();
    const href = await joinLink.getAttribute("href");
    expect(href).toMatch(/wa\.me/);
    const decoded = decodeURIComponent(href ?? "");
    expect(decoded).toMatch(/Mon|Tue|Wed|Thu|Fri|Sat/);
  });

  test.describe("cross-link audit — pricing/membership/schedule/contact all reachable", () => {
    test("pricing links to membership and contact", async ({ page }) => {
      await page.goto("/pricing");
      await expect(page.getByRole("link", { name: /how does joining work/i })).toBeVisible();
      await expect(page.getByRole("link", { name: /enquire about/i }).first()).toBeVisible();
    });

    test("membership links to pricing and contact", async ({ page }) => {
      await page.goto("/membership");
      await expect(page.getByRole("link", { name: /see all plans/i })).toBeVisible();
      await expect(page.getByRole("link", { name: /ask a question/i })).toBeVisible();
    });

    test("schedule links to pricing and contact", async ({ page }) => {
      await page.goto("/schedule");
      await expect(page.getByRole("link", { name: /book a class/i })).toBeVisible();
      await expect(page.getByRole("link", { name: /see plans/i })).toBeVisible();
    });
  });

  test.describe("mobile widths", () => {
    test.use({ viewport: { width: 375, height: 812 } });
    for (const path of ["/pricing", "/membership", "/schedule"]) {
      test(`${path} has no horizontal overflow at 375px`, async ({ page }) => {
        await page.goto(path);
        const overflow = await page.evaluate(() => document.body.scrollWidth > window.innerWidth);
        expect(overflow).toBe(false);
      });
    }
  });
});
