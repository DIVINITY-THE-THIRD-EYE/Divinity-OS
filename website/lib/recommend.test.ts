import { describe, it, expect } from "vitest";
import { recommend } from "./recommend";

describe("recommend", () => {
  it("recommends The Yogi for one-on-one or yearly commitment", () => {
    expect(recommend("Monthly", "Everything", true)).toBe("The Yogi");
    expect(recommend("Yearly", "Everything", false)).toBe("The Yogi");
  });

  it("recommends Drop-in for 'Try it'", () => {
    expect(recommend("Try it", "Everything", false)).toBe("Drop-in");
  });

  it("recommends The Seeker for a single monthly discipline", () => {
    expect(recommend("Monthly", "One discipline", false)).toBe("The Seeker");
  });

  it("defaults to The Devotee", () => {
    expect(recommend("Quarterly", "Everything", false)).toBe("The Devotee");
    expect(recommend("Quarterly", "One discipline", false)).toBe("The Devotee");
  });

  it("prioritises one-on-one over 'Try it'", () => {
    expect(recommend("Try it", "Everything", true)).toBe("The Yogi");
  });
});
