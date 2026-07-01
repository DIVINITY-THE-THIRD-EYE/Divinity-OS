import { ImageResponse } from "next/og";

export const runtime = "edge";
export const alt = "Divinity — The Third Eye";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function OG() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          background:
            "radial-gradient(60% 80% at 75% 30%, rgba(208,138,62,0.22), #15161E 70%)",
          padding: "70px 80px",
          fontFamily: "serif",
        }}
      >
        <div
          style={{
            fontSize: 22,
            letterSpacing: 6,
            textTransform: "uppercase",
            color: "#D08A3E",
            fontFamily: "sans-serif",
          }}
        >
          Yoga · Fitness · Wellness — Lucknow
        </div>

        <div style={{ display: "flex", flexDirection: "column" }}>
          <div style={{ fontSize: 150, color: "#D08A3E", fontStyle: "italic", lineHeight: 1 }}>
            Breathe
          </div>
          <div style={{ fontSize: 88, color: "#ECE7DB", lineHeight: 1.05, marginTop: 6 }}>
            your way inward.
          </div>
        </div>

        <div
          style={{
            fontSize: 26,
            letterSpacing: 4,
            textTransform: "uppercase",
            color: "#8E93A6",
            fontFamily: "sans-serif",
          }}
        >
          Divinity — The Third Eye
        </div>
      </div>
    ),
    { ...size }
  );
}
