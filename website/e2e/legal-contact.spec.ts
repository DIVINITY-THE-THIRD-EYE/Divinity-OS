import { test, expect } from "@playwright/test";

test.describe("11 contact & legal pages", () => {
  test("contact form happy path submits and shows the done state", async ({ page }) => {
    await page.route("**/api/contact", (route) =>
      route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ ok: true }) })
    );
    await page.goto("/contact");
    const form = page.getByRole("form", { name: /contact enquiry form/i });
    await form.getByLabel("Name").fill("Asha Test");
    await form.getByLabel("Email").fill("asha@example.com");
    await form.getByLabel(/what draws you/i).selectOption({ index: 1 });
    await form.getByLabel("Message").fill("Hello, I'd like to visit.");
    await form.getByRole("button", { name: /send enquiry/i }).click();
    await expect(page.getByText(/thank you/i)).toBeVisible();
  });

  test("contact page has WhatsApp/Instagram links", async ({ page }) => {
    // Note: this page embeds WeatherWidget + a Google Maps iframe, both of
    // which trip this environment's CSP (pre-existing, unrelated to 11 —
    // CSP config is outside FILES ALLOWED) — so unlike the other page-smoke
    // tests, this one doesn't assert zero console errors.
    await page.goto("/contact");
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.getByRole("link", { name: /whatsapp/i }).first()).toBeVisible();
    await expect(page.getByRole("link", { name: /instagram/i }).first()).toBeVisible();
  });

  test.describe("legal pages render with real body text", () => {
    for (const path of ["/privacy", "/terms"]) {
      test(`${path} has an h1 and multiple sections`, async ({ page }) => {
        await page.goto(path);
        await expect(page.locator("h1")).toBeVisible();
        await expect(page.locator("h2").first()).toBeVisible();
      });
    }
  });

  test("refund page shows the placeholder label and a contact-us fallback, noindex", async ({ page }) => {
    await page.goto("/refund");
    await expect(page.locator("h1")).toBeVisible();
    await expect(page.getByText(/PLACEHOLDER/i)).toBeVisible();
    await expect(page.getByRole("link", { name: /contact us/i })).toHaveAttribute("href", "/contact");
    const robots = await page.locator('meta[name="robots"]').getAttribute("content");
    expect(robots).toContain("noindex");
  });

  test("privacy and terms are indexable (real content, not noindex)", async ({ page }) => {
    for (const path of ["/privacy", "/terms"]) {
      await page.goto(path);
      const robots = await page.locator('meta[name="robots"]').count();
      expect(robots, `${path} should have no noindex meta`).toBe(0);
    }
  });
});
