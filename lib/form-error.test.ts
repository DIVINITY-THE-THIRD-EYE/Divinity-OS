import { describe, it, expect } from "vitest";
import { formErrorMessage } from "./form-error";

describe("formErrorMessage", () => {
  it("passes through messages from our own thrown Errors (API errors)", () => {
    expect(formErrorMessage(new Error("Please add your name and a valid email."))).toBe(
      "Please add your name and a valid email."
    );
  });

  it("maps a network TypeError to a friendly connection message", () => {
    const msg = formErrorMessage(new TypeError("Failed to fetch"));
    expect(msg).toMatch(/connection/i);
    expect(msg).not.toContain("fetch");
  });

  it("falls back to the connection message for non-Error throwables", () => {
    expect(formErrorMessage("weird")).toMatch(/connection/i);
    expect(formErrorMessage(undefined)).toMatch(/connection/i);
  });
});
