import { test, expect } from "@playwright/test";

test.describe("Home page", () => {
  test("loads with Divinity branding", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/Divinity/i);
  });

  test("shows the trust assurance band", async ({ page }) => {
    await page.goto("/");
    const band = page.getByRole("region", { name: /why you can trust divinity/i });
    await band.scrollIntoViewIfNeeded();
    await expect(band).toBeVisible();
    await expect(band.getByText(/secure upi payments/i)).toBeVisible();
    await expect(band.getByText(/your data stays private/i)).toBeVisible();
  });

  test("exposes primary navigation", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("link", { name: /pricing/i }).first()).toBeVisible();
    await expect(page.getByRole("link", { name: /contact/i }).first()).toBeVisible();
  });
});
