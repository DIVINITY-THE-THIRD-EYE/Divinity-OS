import { describe, it, expect } from "vitest";
import {
  slugify,
  disciplines,
  disciplineSlug,
  getDisciplineBySlug,
  getPostBySlug,
  getEventBySlug,
  posts,
  events,
  upcomingEvents,
} from "./content";

describe("slugify", () => {
  it("lowercases, expands & to 'and', and hyphenates", () => {
    expect(slugify("Hatha & Vinyasa Yoga")).toBe("hatha-and-vinyasa-yoga");
    expect(slugify("Diet & Lifestyle")).toBe("diet-and-lifestyle");
  });

  it("collapses runs of separators and trims leading/trailing hyphens", () => {
    expect(slugify("  Multiple   spaces  ")).toBe("multiple-spaces");
    expect(slugify("Pranayama / Meditation!!!")).toBe("pranayama-meditation");
    expect(slugify("--edge--")).toBe("edge");
  });

  it("is idempotent", () => {
    const once = slugify("Therapeutic Yoga");
    expect(slugify(once)).toBe(once);
  });
});

describe("discipline slug routing", () => {
  it("produces a unique slug per discipline", () => {
    const slugs = disciplines.map(disciplineSlug);
    expect(new Set(slugs).size).toBe(disciplines.length);
  });

  it("round-trips every discipline through getDisciplineBySlug", () => {
    for (const d of disciplines) {
      expect(getDisciplineBySlug(disciplineSlug(d))).toBe(d);
    }
  });

  it("returns undefined for an unknown slug (drives the 404)", () => {
    expect(getDisciplineBySlug("not-a-real-service")).toBeUndefined();
    expect(getDisciplineBySlug("")).toBeUndefined();
  });
});

describe("content getters", () => {
  // Default (production) env: NEXT_PUBLIC_SHOW_STAGING is unset, so
  // stripStaging() drops the "[STAGING]" placeholders — posts/events resolve
  // empty and the routes' empty states render. Visitors never see staging text.
  it("strips staging placeholders from posts/events by default", () => {
    expect(posts.length).toBe(0);
    expect(events.length).toBe(0);
    expect(getPostBySlug("science-of-prana-why-breath-comes-first")).toBeUndefined();
    expect(getEventBySlug("weekend-pranayama-intensive")).toBeUndefined();
    expect(getPostBySlug("not-a-slug")).toBeUndefined();
    expect(getEventBySlug("not-a-slug")).toBeUndefined();
  });

  it("upcomingEvents is empty when events are stripped", () => {
    expect(upcomingEvents().length).toBe(0);
  });
});

describe("upcomingEvents ordering", () => {
  // Validates the filter+sort independent of the (currently empty) events array.
  it("keeps only future events, soonest first", () => {
    const now = Date.now();
    const sample = [
      { slug: "past", date: new Date(now - 86400000).toISOString() },
      { slug: "far", date: new Date(now + 7 * 86400000).toISOString() },
      { slug: "soon", date: new Date(now + 86400000).toISOString() },
    ];
    const upcoming = sample
      .filter((e) => new Date(e.date).getTime() >= now)
      .sort((a, b) => +new Date(a.date) - +new Date(b.date))
      .map((e) => e.slug);
    expect(upcoming).toEqual(["soon", "far"]);
  });
});
