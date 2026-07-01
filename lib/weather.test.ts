import { describe, it, expect } from "vitest";
import { getRecommendation, mapWmoCode, formatTime } from "./weather";

describe("Weather Wellness Recommendation Engine", () => {
  it("recommends indoor practice for unhealthy AQI", () => {
    expect(getRecommendation(25, 105)).toBe("Better to practice indoors today.");
    expect(getRecommendation(40, 150)).toBe("Better to practice indoors today."); // AQI override
  });

  it("recommends restorative sessions for extreme heat (>38C)", () => {
    expect(getRecommendation(39, 45)).toBe("Consider restorative sessions due to heat.");
    expect(getRecommendation(42, 90)).toBe("Consider restorative sessions due to heat.");
  });

  it("recommends staying hydrated for high temperature (35C to 38C)", () => {
    expect(getRecommendation(36, 30)).toBe("Stay hydrated during afternoon classes.");
    expect(getRecommendation(37, 75)).toBe("Stay hydrated during afternoon classes.");
  });

  it("recommends outdoor yoga for good AQI and pleasant temperature (18C to 30C)", () => {
    expect(getRecommendation(22, 10)).toBe("Excellent day for outdoor yoga.");
    expect(getRecommendation(28, 48)).toBe("Excellent day for outdoor yoga.");
  });

  it("recommends indoor dynamic warmup for cold temperatures (<15C)", () => {
    expect(getRecommendation(12, 20)).toBe("Warm up dynamically indoors today.");
    expect(getRecommendation(5, 80)).toBe("Warm up dynamically indoors today.");
  });

  it("recommends good pranayama conditions as a sensible fallback", () => {
    expect(getRecommendation(32, 60)).toBe("Good conditions for pranayama.");
    expect(getRecommendation(16, 70)).toBe("Good conditions for pranayama.");
  });
});

describe("WMO Code Mapper", () => {
  it("maps codes to text and emojis", () => {
    expect(mapWmoCode(0)).toEqual({ text: "Clear Sky", icon: "☀️" });
    expect(mapWmoCode(2)).toEqual({ text: "Partly Cloudy", icon: "🌤️" });
    expect(mapWmoCode(63)).toEqual({ text: "Rainy", icon: "🌧️" });
    expect(mapWmoCode(-5)).toEqual({ text: "Cloudy", icon: "☁️" }); // default fallback
  });
});

describe("Time Formatter", () => {
  it("formats ISO timestamps to local time", () => {
    expect(formatTime("2026-06-30T06:05:00Z")).toMatch(/AM|PM/);
    expect(formatTime("invalid-date")).toBe("--:--");
  });
});
