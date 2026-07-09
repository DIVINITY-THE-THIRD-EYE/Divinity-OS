import { test, expect } from "@playwright/test";

test.describe("12 student login / portal", () => {
  test("/portal unauthenticated redirects to /login", async ({ page }) => {
    await page.goto("/portal");
    await expect(page).toHaveURL(/\/login/);
  });

  test("/login renders the phone-entry form", async ({ page }) => {
    await page.goto("/login");
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.getByLabel(/phone number/i)).toBeVisible();
    await expect(page.getByRole("button", { name: /send code/i })).toBeVisible();
  });

  test("/login shows the non-student message when redirected with error=not-student", async ({ page }) => {
    await page.goto("/login?error=not-student");
    await expect(page.getByText(/this portal is for students/i)).toBeVisible();
  });

  test("/login rejects a malformed phone number client-side", async ({ page }) => {
    await page.goto("/login");
    await page.getByLabel(/phone number/i).fill("9876543210"); // missing +
    await page.getByRole("button", { name: /send code/i }).click();
    await expect(page.getByText(/international format/i)).toBeVisible();
  });
});
