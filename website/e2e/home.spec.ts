import { test, expect } from "@playwright/test";

test.describe("Home page", () => {
  test("loads with Divinity branding", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/Divinity/i);
  });

  test("exposes primary navigation", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("link", { name: /pricing/i }).first()).toBeVisible();
    await expect(page.getByRole("link", { name: /contact/i }).first()).toBeVisible();
  });

  test("renders all 9 homepage sections in order", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("heading", { name: /breathe/i }).first()).toBeVisible();
    await expect(page.getByRole("heading", { name: /before the body moves/i })).toBeVisible();
    await expect(page.getByText(/what we practice/i)).toBeVisible();
    await expect(page.getByRole("heading", { name: /why members stay/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /taught by/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /where the practice/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /your first/i })).toBeVisible();
  });

  test("final CTA's batch picker builds a wa.me link", async ({ page }) => {
    await page.goto("/");
    const finalCta = page.locator("#final-cta-heading").locator("..");
    await finalCta.scrollIntoViewIfNeeded();
    const waLink = finalCta.locator('a[href*="wa.me"]');
    await expect(waLink.first()).toBeVisible();
    await expect(waLink.first()).toHaveAttribute("href", /wa\.me/);
  });

  test("scrolling advances the act-break light shift (ScrollScore is live)", async ({ page }) => {
    await page.goto("/");
    await page.waitForTimeout(2000); // idle-callback deferred GSAP init
    await page.mouse.wheel(0, 4000);
    await expect(page.locator("html")).toHaveAttribute("data-act", /^[123]$/);
  });

  test("reduced motion: all section headings are still visible (ScrollScore mounts nothing)", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto("/");
    await expect(page.getByRole("heading", { name: /breathe/i }).first()).toBeVisible();
    await expect(page.getByRole("heading", { name: /before the body moves/i })).toBeVisible();
    await expect(page.getByText(/what we practice/i)).toBeVisible();
    await expect(page.getByRole("heading", { name: /why members stay/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /taught by/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /where the practice/i })).toBeVisible();
    await expect(page.getByRole("heading", { name: /your first/i })).toBeVisible();
    // ScrollScore's effect returns early under reduced motion — no data-act attribute.
    await expect(page.locator("html")).not.toHaveAttribute("data-act", /.+/);
  });

  test("?no-motion=1 also skips ScrollScore", async ({ page }) => {
    await page.goto("/?no-motion=1");
    await page.mouse.wheel(0, 2000);
    await expect(page.locator("html")).not.toHaveAttribute("data-act", /.+/);
  });
});
