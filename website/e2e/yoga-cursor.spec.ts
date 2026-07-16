import { test, expect } from "@playwright/test";

const CURSOR_SELECTOR = 'div[class*="mix-blend-difference"]';

test.describe("Yoga cursor", () => {
  test("pose changes as the page scrolls", async ({ page }) => {
    await page.goto("/");
    await page.waitForTimeout(2000); // idle-callback deferred GSAP init (05)
    const getPose = () =>
      page.evaluate((sel) => {
        const svg = document.querySelector(`${sel} svg`);
        const visible = Array.from(svg!.querySelectorAll("g")).find(
          (g) => g.style.opacity === "1"
        );
        return visible ? visible.querySelector("path")!.getAttribute("d") : null;
      }, CURSOR_SELECTOR);

    const poseAtTop = await getPose();
    await page.mouse.wheel(0, 5000);
    await page.waitForTimeout(300);
    const poseAfterScroll = await getPose();
    expect(poseAfterScroll).not.toBe(poseAtTop);
  });

  test("hover on a link grows it and shifts color", async ({ page }) => {
    await page.goto("/");
    const link = page.locator('nav a[href="/pricing"]');
    await link.hover();
    await page.waitForTimeout(350);
    const svg = page.locator(`${CURSOR_SELECTOR} svg`);
    await expect(svg).toHaveAttribute("width", "40");
  });

  test("absent under reduced motion", async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto("/");
    await page.waitForTimeout(1000);
    await expect(page.locator(CURSOR_SELECTOR)).toHaveCount(0);
  });

  test.describe("coarse pointer (touch)", () => {
    test.use({ hasTouch: true, isMobile: true, viewport: { width: 390, height: 844 } });
    test("absent on touch devices — native cursor stays", async ({ page }) => {
      await page.goto("/");
      await page.waitForTimeout(1000);
      await expect(page.locator(CURSOR_SELECTOR)).toHaveCount(0);
    });
  });
});
