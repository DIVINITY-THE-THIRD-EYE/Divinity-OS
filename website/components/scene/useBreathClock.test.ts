import { describe, it, expect } from "vitest";
import { breathAt } from "./useBreathClock";

// 06_YOGA_CURSOR... no, 07_SCENE_3D.md step 1: "phase values at t=0,4,8,14
// match old breathAt" (inhale 4 · hold 4 · exhale 6 · cycle 14).
describe("breathAt", () => {
  it("t=0 — start of inhale, breath 0", () => {
    const p = breathAt(0);
    expect(p.label).toBe("Inhale");
    expect(p.breath).toBeCloseTo(0, 5);
    expect(p.remaining).toBeCloseTo(4, 5);
  });

  it("t=4 — start of hold, breath 1", () => {
    const p = breathAt(4);
    expect(p.label).toBe("Hold");
    expect(p.breath).toBeCloseTo(1, 5);
    expect(p.remaining).toBeCloseTo(4, 5);
  });

  it("t=8 — start of exhale, breath 1", () => {
    const p = breathAt(8);
    expect(p.label).toBe("Exhale");
    expect(p.breath).toBeCloseTo(1, 5);
    expect(p.remaining).toBeCloseTo(6, 5);
  });

  it("t=14 — cycle wraps back to start of inhale", () => {
    const p = breathAt(14);
    expect(p.label).toBe("Inhale");
    expect(p.breath).toBeCloseTo(0, 5);
    expect(p.remaining).toBeCloseTo(4, 5);
  });

  it("midpoint of exhale is roughly half fullness", () => {
    const p = breathAt(11); // 3s into the 6s exhale
    expect(p.label).toBe("Exhale");
    expect(p.breath).toBeCloseTo(0.5, 1);
  });
});
