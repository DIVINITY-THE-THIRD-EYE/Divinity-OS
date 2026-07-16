import { test, expect } from "@playwright/test";

test.describe("Navigation & key pages", () => {
  test("navigates from home to pricing", async ({ page }) => {
    await page.goto("/");
    const cta = page.getByRole("link", { name: /pricing/i }).first();
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
    for (const path of [
      "/about",
      "/founder",
      "/programs",
      "/programs/therapeutic-yoga",
      "/programs/meditation",
      "/schedule",
      "/trainers",
      "/verify",
    ]) {
      const res = await page.goto(path);
      expect(res?.status(), `GET ${path}`).toBeLessThan(400);
    }
  });

  test("/services redirects permanently to /programs", async ({ page }) => {
    const res = await page.goto("/services");
    expect(res?.status()).toBeLessThan(400);
    await expect(page).toHaveURL(/\/programs$/);
  });

  test("/services/:slug redirects to /programs/:slug", async ({ page }) => {
    const res = await page.goto("/services/hatha-and-vinyasa-yoga");
    expect(res?.status()).toBeLessThan(400);
    await expect(page).toHaveURL(/\/programs\/hatha-and-vinyasa-yoga$/);
  });

  test.describe("08 core pages — h1 present, no console errors", () => {
    const routes = ["/about", "/founder", "/trainers", "/programs", "/programs/therapeutic-yoga", "/programs/meditation"];
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
  });
});
