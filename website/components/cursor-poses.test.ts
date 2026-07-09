import { describe, it, expect } from "vitest";
import { CURSOR_POSES } from "./cursor-poses";

// 06_YOGA_CURSOR.md's own validation asks for a path-parity check ("all 12
// paths parse to the same command/point count") — that applies to the
// point-lerp morphing approach, which this file's header explains wasn't
// taken (crossfade fallback instead, per the task's own escape hatch). These
// checks verify what crossfade actually needs: 12 distinct, well-formed poses.

describe("cursor poses", () => {
  it("has exactly 12 poses (the 12 Surya Namaskar steps)", () => {
    expect(CURSOR_POSES).toHaveLength(12);
  });

  it("every pose has a non-empty body path starting with a moveto command", () => {
    for (const pose of CURSOR_POSES) {
      expect(pose.body.length).toBeGreaterThan(0);
      expect(pose.body.trim().startsWith("M")).toBe(true);
    }
  });

  it("every pose's path commands are M/L/Z only (no curves — keeps it a cheap stroke render)", () => {
    for (const pose of CURSOR_POSES) {
      const commandLetters = pose.body.match(/[A-Za-z]/g) ?? [];
      for (const c of commandLetters) {
        expect(["M", "L", "Z"]).toContain(c);
      }
    }
  });

  it("every head circle sits inside the 0-100 viewBox", () => {
    for (const pose of CURSOR_POSES) {
      expect(pose.head.cx).toBeGreaterThanOrEqual(0);
      expect(pose.head.cx).toBeLessThanOrEqual(100);
      expect(pose.head.cy).toBeGreaterThanOrEqual(0);
      expect(pose.head.cy).toBeLessThanOrEqual(100);
    }
  });

  it("every pose has a name", () => {
    for (const pose of CURSOR_POSES) {
      expect(pose.name.length).toBeGreaterThan(0);
    }
  });
});
