"use client";

import { useEffect } from "react";
import ErrorContent from "@/components/layout/ErrorContent";

export default function MarketingError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("[marketing] runtime error:", error);
  }, [error]);

  return <ErrorContent reset={reset} />;
}
