"use client";

import { useEffect } from "react";

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

  return (
    <main className="flex min-h-[100svh] flex-col items-center justify-center bg-void px-6 text-center">
      <p className="eyebrow mb-6 text-ember">Something interrupted the breath</p>
      <h1 className="font-display text-[clamp(40px,8vw,96px)] font-light italic leading-none text-bone">
        A moment&apos;s pause.
      </h1>
      <p className="mt-6 max-w-md font-body text-base leading-relaxed text-mist">
        Something went wrong on our side. Take a breath and try again — your place
        in the practice is safe.
      </p>
      <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
        <button
          onClick={reset}
          className="bg-ember px-8 py-3.5 font-mono text-[11px] uppercase tracking-wide text-void transition-colors hover:bg-ember-pale"
        >
          Try again
        </button>
        <a
          href="/"
          className="font-mono text-[11px] uppercase tracking-wide text-mist transition-colors hover:text-bone"
        >
          Return home
        </a>
      </div>
    </main>
  );
}
