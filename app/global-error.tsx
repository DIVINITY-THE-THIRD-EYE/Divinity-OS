"use client";

import { useEffect } from "react";

// Catches errors thrown in the root layout itself. It replaces <html>/<body>,
// so it cannot rely on globals.css or fonts — styles are inlined.
export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("[app] root error:", error);
  }, [error]);

  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          minHeight: "100vh",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          gap: "1.5rem",
          background: "#15161e",
          color: "#ece7db",
          fontFamily: "Georgia, serif",
          textAlign: "center",
          padding: "0 1.5rem",
        }}
      >
        <h1 style={{ fontStyle: "italic", fontWeight: 300, fontSize: "clamp(40px,8vw,80px)", margin: 0, color: "#d08a3e" }}>
          A moment&apos;s pause.
        </h1>
        <p style={{ maxWidth: "28rem", lineHeight: 1.8, color: "#8e93a6", margin: 0 }}>
          Something went wrong. Please try again.
        </p>
        <button
          onClick={reset}
          style={{
            background: "#d08a3e",
            color: "#15161e",
            border: "none",
            padding: "0.9rem 2rem",
            fontFamily: "monospace",
            fontSize: "11px",
            letterSpacing: "0.1em",
            textTransform: "uppercase",
            cursor: "pointer",
          }}
        >
          Try again
        </button>
      </body>
    </html>
  );
}
