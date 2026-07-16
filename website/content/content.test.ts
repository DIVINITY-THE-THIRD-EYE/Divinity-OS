import { describe, it, expect } from "vitest";
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import * as content from "./index";
import { site } from "./site";
import { contact } from "./contact";

describe("every content module exports non-empty data", () => {
  const nonEmpty = (v: unknown): boolean => {
    if (Array.isArray(v)) return v.length > 0;
    if (v && typeof v === "object") return Object.keys(v).length > 0;
    if (typeof v === "string") return v.length > 0;
    if (typeof v === "function") return true; // getters/helpers
    return v != null;
  };

  // Staging-gated exports (see lib/staging.ts) resolve empty in the default
  // env by design — they leak "[STAGING]" text otherwise. Their populated/empty
  // behavior is covered in lib/content.test.ts; skip them here.
  const stagingGated = new Set(["testimonials", "events", "posts"]);

  for (const [name, value] of Object.entries(content)) {
    if (stagingGated.has(name)) continue;
    it(`content.${name} is non-empty`, () => {
      expect(nonEmpty(value)).toBe(true);
    });
  }
});

describe("site/contact critical fields are real, never placeholders", () => {
  const critical: Record<string, string> = {
    "site.name": site.name,
    "site.url": site.url,
    "contact.phone": contact.phone,
    "contact.whatsapp": contact.whatsapp,
  };

  for (const [field, value] of Object.entries(critical)) {
    it(`${field} is not a placeholder`, () => {
      expect(value).not.toMatch(/\[PLACEHOLDER:/);
      expect(value.length).toBeGreaterThan(0);
    });
  }
});

describe("every [PLACEHOLDER: has a matching TODO(PH- comment in the same file", () => {
  const dir = __dirname;
  const files = readdirSync(dir).filter((f) => f.endsWith(".ts") && !f.endsWith(".test.ts"));

  for (const file of files) {
    it(`${file}`, () => {
      const text = readFileSync(join(dir, file), "utf8");
      const hasPlaceholder = /\[PLACEHOLDER:/.test(text);
      if (!hasPlaceholder) return;
      expect(text).toMatch(/TODO\(PH-/);
    });
  }
});
