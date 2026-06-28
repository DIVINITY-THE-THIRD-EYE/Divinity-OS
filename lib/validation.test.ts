import { describe, it, expect } from "vitest";
import { isEmail } from "./validation";

describe("isEmail", () => {
  it("accepts well-formed addresses", () => {
    for (const v of ["a@b.co", "name.surname@example.in", "x+tag@mail.example.com"]) {
      expect(isEmail(v)).toBe(true);
    }
  });

  it("rejects malformed addresses", () => {
    for (const v of ["", "no-at", "a@b", "a@@b.co", "a b@c.co", "a@b .co", "@b.co"]) {
      expect(isEmail(v)).toBe(false);
    }
  });
});
