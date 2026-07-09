import { describe, it, expect } from "vitest";
import {
  pageMeta,
  absUrl,
  buildLocalBusinessJsonLd,
  buildFaqJsonLd,
  buildCourseJsonLd,
  buildPersonJsonLd,
} from "./seo";
import { site } from "./content";

/** Round-trips through JSON to mimic what actually reaches the page (JsonLd
 * components always JSON.stringify before rendering into a <script> tag). */
const roundTrip = (value: unknown) => JSON.parse(JSON.stringify(value));

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

  it("sets a noindex robots meta only when asked", () => {
    const indexed = pageMeta({ title: "T", description: "d", path: "/faq" });
    expect(indexed.robots).toBeUndefined();

    const blocked = pageMeta({ title: "T", description: "d", path: "/refund", noindex: true });
    expect(blocked.robots).toEqual({ index: false, follow: true });
  });
});

describe("absUrl", () => {
  it("joins paths onto the site origin and keeps a single root slash", () => {
    const base = site.url.replace(/\/$/, "");
    expect(absUrl("/")).toBe(base + "/");
    expect(absUrl("/services/x")).toBe(base + "/services/x");
  });
});

describe("buildLocalBusinessJsonLd", () => {
  it("emits a valid, parseable LocalBusiness-family block with required fields", () => {
    const data = roundTrip(buildLocalBusinessJsonLd(site));
    expect(data["@context"]).toBe("https://schema.org");
    expect(data["@type"]).toContain("HealthAndBeautyBusiness");
    expect(data.name).toBe(site.full);
    expect(data.address["@type"]).toBe("PostalAddress");
    expect(data.geo).toBeUndefined();
  });

  it("includes geo coordinates when provided", () => {
    const data = roundTrip(buildLocalBusinessJsonLd(site, { latitude: 26.8467, longitude: 80.9462 }));
    expect(data.geo).toEqual({ "@type": "GeoCoordinates", latitude: 26.8467, longitude: 80.9462 });
  });
});

describe("buildFaqJsonLd", () => {
  it("maps each FAQ into a Question/Answer pair", () => {
    const data = roundTrip(buildFaqJsonLd([{ q: "Q1?", a: "A1." }, { q: "Q2?", a: "A2." }]));
    expect(data["@type"]).toBe("FAQPage");
    expect(data.mainEntity).toHaveLength(2);
    expect(data.mainEntity[0]).toEqual({
      "@type": "Question",
      name: "Q1?",
      acceptedAnswer: { "@type": "Answer", text: "A1." },
    });
  });
});

describe("buildCourseJsonLd", () => {
  it("emits a valid Course block with a provider", () => {
    const data = roundTrip(
      buildCourseJsonLd({
        name: "Hatha & Vinyasa Yoga",
        description: "d",
        url: absUrl("/programs/hatha-and-vinyasa-yoga"),
        providerName: site.full,
        providerUrl: absUrl("/"),
      })
    );
    expect(data["@type"]).toBe("Course");
    expect(data.name).toBe("Hatha & Vinyasa Yoga");
    expect(data.provider).toEqual({ "@type": "Organization", name: site.full, url: absUrl("/") });
  });
});

describe("buildPersonJsonLd", () => {
  it("emits real credentials but filters out placeholder-labeled ones", () => {
    const data = roundTrip(
      buildPersonJsonLd({
        name: "Sachin Rajvanshi",
        jobTitle: "Founder & Guide",
        url: absUrl("/founder"),
        worksForName: site.full,
        credentials: ["RYT-500", "[PLACEHOLDER: founder credentials — see PLACEHOLDERS.md PH-002]"],
      })
    );
    expect(data["@type"]).toBe("Person");
    expect(data.hasCredential).toEqual(["RYT-500"]);
  });

  it("omits hasCredential entirely when every credential is a placeholder", () => {
    const data = roundTrip(
      buildPersonJsonLd({
        name: "Sachin Rajvanshi",
        jobTitle: "Founder & Guide",
        url: absUrl("/founder"),
        worksForName: site.full,
        credentials: ["[PLACEHOLDER: founder credentials — see PLACEHOLDERS.md PH-002]"],
      })
    );
    expect(data.hasCredential).toBeUndefined();
  });
});
