import { describe, it, expect } from "vitest";
import { stripStaging } from "./staging";

// The module reads NEXT_PUBLIC_SHOW_STAGING once at import; these tests run in
// the default (unset) env, so stripStaging is in production/filtering mode.
describe("stripStaging (production mode)", () => {
  const rows = [
    { title: "[STAGING] Fake", body: "x" },
    { title: "Real Article", body: "[STAGING CONTENT] leaked body" },
    { title: "Clean", body: "clean" },
  ];

  it("drops entries whose inspected field starts with a [STAGING marker", () => {
    expect(stripStaging(rows, ["title"]).map((r) => r.title)).toEqual([
      "Real Article",
      "Clean",
    ]);
  });

  it("inspects every named field (leading whitespace ignored)", () => {
    expect(stripStaging(rows, ["title", "body"]).map((r) => r.title)).toEqual([
      "Clean",
    ]);
  });

  it("keeps everything when no field carries a marker", () => {
    const clean = [{ q: "a" }, { q: "b" }];
    expect(stripStaging(clean, ["q"])).toHaveLength(2);
  });
});
