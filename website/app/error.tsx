"use client";

import { useEffect } from "react";
import ErrorContent from "@/components/layout/ErrorContent";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Surface for server logs / future error monitoring (Sentry).
    console.error("[app] runtime error:", error);
  }, [error]);

  return <ErrorContent reset={reset} />;
}
