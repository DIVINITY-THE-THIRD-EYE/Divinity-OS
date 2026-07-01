import { describe, it, expect } from "vitest";
import { pageMeta, absUrl } from "./seo";
import { site } from "./content";

describe("pageMeta", () => {
  it("suffixes the brand name and sets a relative canonical", () => {
    const m = pageMeta({ title: "About the Academy", description: "d", path: "/about" });
    expect(m.title).toBe(`About the Academy · ${site.full}`);
    expect(m.description).toBe("d");
    expect(m.alternates?.canonical).toBe("/about");
  });

  it("builds an absolute openGraph url and defaults to website type", () => {
    const m = pageMeta({ title: "T", description: "d", path: "/pricing" });
    const og = m.openGraph as { url?: string; type?: string };
    expect(og.url).toBe(`${site.url.replace(/\/$/, "")}/pricing`);
    expect(og.type).toBe("website");
  });

  it("does not double-suffix when the title is already the brand name", () => {
    const m = pageMeta({ title: site.full, description: "d", path: "/" });
    expect(m.title).toBe(site.full);
  });

  it("passes through article type and an OG image", () => {
    const m = pageMeta({ title: "Post", description: "d", path: "/blog/x", type: "article", image: "/c.jpg" });
    const og = m.openGraph as { type?: string; images?: Array<{ url: string }> };
    expect(og.type).toBe("article");
    expect(og.images?.[0]?.url).toBe("/c.jpg");
  });
});

describe("absUrl", () => {
  it("joins paths onto the site origin and keeps a single root slash", () => {
    const base = site.url.replace(/\/$/, "");
    expect(absUrl("/")).toBe(base + "/");
    expect(absUrl("/services/x")).toBe(base + "/services/x");
  });
});
