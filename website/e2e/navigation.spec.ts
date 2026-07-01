import { test, expect } from "@playwright/test";

test.describe("Navigation & key pages", () => {
  test("navigates from home to pricing", async ({ page }) => {
    await page.goto("/");
    // Use the visible mid-page membership CTA (the nav "Pricing" link can live in
    // a collapsed mobile menu depending on viewport).
    const cta = page.getByRole("link", { name: /see all plans/i }).first();
    await cta.scrollIntoViewIfNeeded();
    await cta.click();
    await expect(page).toHaveURL(/\/pricing/);
  });

  test("contact page exposes an email field", async ({ page }) => {
    await page.goto("/contact");
    await expect(page).toHaveURL(/\/contact/);
    await expect(page.locator('input[type="email"]').first()).toBeVisible();
  });

  test("core marketing routes return 200", async ({ page }) => {
    for (const path of ["/about", "/services", "/schedule", "/trainers", "/verify"]) {
      const res = await page.goto(path);
      expect(res?.status(), `GET ${path}`).toBeLessThan(400);
    }
  });
});
