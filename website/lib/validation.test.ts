import { describe, it, expect } from "vitest";
import { isEmail, asString, isPlainObject, declaredBodyTooLarge } from "./validation";

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

describe("asString", () => {
  it("returns strings unchanged and coerces everything else to ''", () => {
    expect(asString("hi")).toBe("hi");
    expect(asString(42)).toBe("");
    expect(asString(null)).toBe("");
    expect(asString(undefined)).toBe("");
    expect(asString({})).toBe("");
    expect(asString(["a"])).toBe("");
  });
});

describe("isPlainObject", () => {
  it("is true only for non-null, non-array objects", () => {
    expect(isPlainObject({})).toBe(true);
    expect(isPlainObject({ a: 1 })).toBe(true);
    expect(isPlainObject(null)).toBe(false);
    expect(isPlainObject([])).toBe(false);
    expect(isPlainObject("x")).toBe(false);
    expect(isPlainObject(7)).toBe(false);
  });
});

describe("declaredBodyTooLarge", () => {
  const req = (headers: Record<string, string>) =>
    new Request("http://localhost/api", { method: "POST", headers });

  it("rejects a body whose declared length exceeds the cap", () => {
    expect(declaredBodyTooLarge(req({ "content-length": "20000" }))).toBe(true);
  });

  it("allows a body within the cap", () => {
    expect(declaredBodyTooLarge(req({ "content-length": "500" }))).toBe(false);
  });

  it("allows requests with no/!numeric content-length (falls through to field guards)", () => {
    expect(declaredBodyTooLarge(req({}))).toBe(false);
    expect(declaredBodyTooLarge(req({ "content-length": "not-a-number" }))).toBe(false);
  });

  it("honours a custom cap", () => {
    expect(declaredBodyTooLarge(req({ "content-length": "100" }), 50)).toBe(true);
    expect(declaredBodyTooLarge(req({ "content-length": "40" }), 50)).toBe(false);
  });
});
