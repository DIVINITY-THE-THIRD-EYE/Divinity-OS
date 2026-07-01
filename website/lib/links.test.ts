import { describe, it, expect } from "vitest";
import { waHref } from "./links";

describe("waHref", () => {
  it("builds a bare wa.me link when given no message", () => {
    expect(waHref()).toMatch(/^https:\/\/wa\.me\/\d+$/);
  });

  it("appends a URL-encoded text param when given a message", () => {
    const url = waHref("Hello world & co.");
    expect(url).toContain("?text=");
    expect(url).toContain("Hello%20world%20%26%20co.");
    // round-trips back to the original message
    const text = new URL(url).searchParams.get("text");
    expect(text).toBe("Hello world & co.");
  });
});
