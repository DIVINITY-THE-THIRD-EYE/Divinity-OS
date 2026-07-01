import { test, expect } from "@playwright/test";

test.describe("Certificate verification (/verify)", () => {
  test("renders the verify form", async ({ page }) => {
    await page.goto("/verify");
    await expect(page.getByPlaceholder("DIV-XXXX-XXXX")).toBeVisible();
    await expect(page.getByRole("button", { name: /verify/i })).toBeVisible();
  });

  test("rejects an invalid code format", async ({ page }) => {
    await page.goto("/verify");
    await page.getByPlaceholder("DIV-XXXX-XXXX").fill("not-a-code");
    await page.getByRole("button", { name: /verify/i }).click();
    await expect(
      page.getByText(/doesn.t look like a divinity certificate code/i),
    ).toBeVisible();
  });

  test("well-formed code returns the graceful 'unavailable' fallback", async ({ page }) => {
    await page.goto("/verify");
    await page.getByPlaceholder("DIV-XXXX-XXXX").fill("DIV-7K2A-9QF3");
    await page.getByRole("button", { name: /verify/i }).click();
    // Unique to the API's graceful fallback response (no CERT_VERIFY_ENDPOINT set).
    await expect(
      page.getByText(/online verification isn.t enabled yet/i),
    ).toBeVisible();
  });
});
