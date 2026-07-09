import { describe, it, expect } from "vitest";
import { isStudent } from "./role-gate";

describe("isStudent", () => {
  it("passes a user whose JWT role claim is student", () => {
    expect(isStudent({ app_metadata: { role: "student" } })).toBe(true);
  });

  it("rejects trainer and admin", () => {
    expect(isStudent({ app_metadata: { role: "trainer" } })).toBe(false);
    expect(isStudent({ app_metadata: { role: "admin" } })).toBe(false);
  });

  it("rejects a missing/null/empty role claim", () => {
    expect(isStudent({ app_metadata: { role: null } })).toBe(false);
    expect(isStudent({ app_metadata: { role: "" } })).toBe(false);
    expect(isStudent({ app_metadata: {} })).toBe(false);
    expect(isStudent({})).toBe(false);
  });

  it("rejects a missing session entirely", () => {
    expect(isStudent(null)).toBe(false);
    expect(isStudent(undefined)).toBe(false);
  });
});
