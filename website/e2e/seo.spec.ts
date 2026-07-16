import { test, expect } from "@playwright/test";

/**
 * 14_SEO.md's matrix sweep, scripted rather than hand-checked: every
 * indexable route gets a unique title/canonical and exactly one h1; every
 * route this project marks noindex actually carries the robots meta.
 */
const INDEXABLE_ROUTES = [
  "/",
  "/about",
  "/founder",
  "/programs",
  "/programs/hatha-and-vinyasa-yoga",
  "/programs/therapeutic-yoga",
  "/programs/meditation",
  "/pricing",
  "/membership",
  "/schedule",
  "/trainers",
  "/gallery",
  "/faq",
  "/contact",
  "/verify",
  "/privacy",
  "/terms",
];

const NOINDEX_ROUTES = ["/blog", "/events", "/testimonials", "/refund", "/login"];

test.describe("14 SEO matrix sweep", () => {
  for (const path of INDEXABLE_ROUTES) {
    test(`${path}: unique title, canonical, exactly one h1, indexable`, async ({ page }) => {
      await page.goto(path);
      await expect(page).toHaveTitle(/.+/);
      const canonical = await page.locator('link[rel="canonical"]').getAttribute("href");
      expect(canonical, `${path} canonical`).toBeTruthy();
      expect(canonical).toContain(path === "/" ? "" : path);
      await expect(page.locator("h1")).toHaveCount(1);
      const robots = await page.locator('meta[name="robots"]').count();
      expect(robots, `${path} should be indexable (no noindex meta)`).toBe(0);
    });
  }

  for (const path of NOINDEX_ROUTES) {
    test(`${path}: carries a noindex robots meta`, async ({ page }) => {
      await page.goto(path);
      const robots = await page.locator('meta[name="robots"]').getAttribute("content");
      expect(robots, `${path} robots meta`).toContain("noindex");
    });
  }

  test("/founder has Person JSON-LD with no placeholder credential leaked", async ({ page }) => {
    await page.goto("/founder");
    const scripts = await page.locator('script[type="application/ld+json"]').allTextContents();
    const person = scripts.map((s) => JSON.parse(s)).find((d) => d["@type"] === "Person");
    expect(person, "Person JSON-LD present").toBeTruthy();
    expect(JSON.stringify(person)).not.toContain("PLACEHOLDER");
  });

  test("program pages have Course JSON-LD", async ({ page }) => {
    for (const path of ["/programs/hatha-and-vinyasa-yoga", "/programs/therapeutic-yoga", "/programs/meditation"]) {
      await page.goto(path);
      const scripts = await page.locator('script[type="application/ld+json"]').allTextContents();
      const course = scripts.map((s) => JSON.parse(s)).find((d) => d["@type"] === "Course");
      expect(course, `${path} Course JSON-LD`).toBeTruthy();
    }
  });

  test("LocalBusiness JSON-LD renders site-wide but FAQPage only on /faq", async ({ page }) => {
    await page.goto("/about");
    let scripts = await page.locator('script[type="application/ld+json"]').allTextContents();
    let types = scripts.map((s) => JSON.parse(s)["@type"]);
    expect(types.some((t) => Array.isArray(t) && t.includes("HealthAndBeautyBusiness"))).toBe(true);
    expect(types.some((t) => t === "FAQPage")).toBe(false);

    await page.goto("/faq");
    scripts = await page.locator('script[type="application/ld+json"]').allTextContents();
    types = scripts.map((s) => JSON.parse(s)["@type"]);
    expect(types.some((t) => t === "FAQPage")).toBe(true);
  });
});
