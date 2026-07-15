import { test, expect } from "@playwright/test";

test.describe("12 student login / portal", () => {
  test("/portal unauthenticated redirects to /login", async ({ page }) => {
    await page.goto("/portal");
    await expect(page).toHaveURL(/\/login/);
  });

  test("/login renders the email sign-in form", async ({ page }) => {
    await page.goto("/login");
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.getByLabel(/email address/i)).toBeVisible();
    await expect(page.getByLabel(/password/i)).toBeVisible();
    await expect(page.getByRole("button", { name: /sign in/i })).toBeVisible();
  });

  test("/login shows the non-student message when redirected with error=not-student", async ({ page }) => {
    await page.goto("/login?error=not-student");
    await expect(page.getByText(/this portal is for students/i)).toBeVisible();
  });

  test("/login rejects a malformed email via native validation before any network call", async ({ page }) => {
    await page.goto("/login");
    const email = page.getByLabel(/email address/i);
    await email.fill("not-an-email");
    await page.getByLabel(/password/i).fill("irrelevant");
    await page.getByRole("button", { name: /sign in/i }).click();
    // type="email" blocks submission client-side; the browser marks the field invalid.
    const invalid = await email.evaluate((el) => !(el as HTMLInputElement).checkValidity());
    expect(invalid).toBe(true);
    await expect(page).toHaveURL(/\/login/);
  });

  test("13: Nav exposes a Student Login link that opens /login", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("link", { name: /student login/i }).first().click();
    await expect(page).toHaveURL(/\/login/);
  });
});
