import { assurances, type Assurance } from "@/lib/content";

// Dependency-free inline icons (stroke uses currentColor → inherits ember).
function Icon({ name }: { name: Assurance["icon"] }) {
  const common = {
    width: 24,
    height: 24,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.5,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true,
  };
  switch (name) {
    case "shield":
      return (
        <svg {...common}>
          <path d="M12 3l7 3v5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z" />
          <path d="M9 12l2 2 4-4" />
        </svg>
      );
    case "guide":
      return (
        <svg {...common}>
          <circle cx="12" cy="8" r="3.2" />
          <path d="M5.5 20a6.5 6.5 0 0113 0" />
        </svg>
      );
    case "users":
      return (
        <svg {...common}>
          <circle cx="9" cy="9" r="3" />
          <path d="M3.5 19a5.5 5.5 0 0111 0" />
          <path d="M16 6.5a3 3 0 010 5.8" />
          <path d="M17 13.4A5.5 5.5 0 0120.5 18.5" />
        </svg>
      );
    case "lock":
      return (
        <svg {...common}>
          <rect x="5" y="11" width="14" height="9" rx="2" />
          <path d="M8 11V8a4 4 0 018 0v3" />
        </svg>
      );
    case "spark":
      return (
        <svg {...common}>
          <path d="M12 3v4M12 17v4M3 12h4M17 12h4" />
          <path d="M12 8.5l1.5 2 2 .5-2 1.5-.5 2-1.5-2-2-.5 2-1.5z" />
        </svg>
      );
    case "badge":
      return (
        <svg {...common}>
          <circle cx="12" cy="10" r="5" />
          <path d="M9 14.5L8 21l4-2 4 2-1-6.5" />
        </svg>
      );
  }
}

// Why trust Divinity — assurance band. Static (server-rendered): no client JS,
// no layout shift. Content lives in lib/content.ts (`assurances`) so the owner
// can edit it without touching this component.
export default function TrustBadges() {
  return (
    <section
      aria-label="Why you can trust Divinity"
      className="border-y border-[var(--line-dark)] bg-deep px-6 py-16 md:px-10 md:py-20"
    >
      <div className="mx-auto max-w-6xl">
        <p className="eyebrow mb-10 text-center text-ember">Why members trust us</p>
        <ul className="grid grid-cols-1 gap-x-10 gap-y-8 sm:grid-cols-2 lg:grid-cols-3">
          {assurances.map((a) => (
            <li key={a.title} className="flex items-start gap-4">
              <span
                className="mt-0.5 inline-flex h-11 w-11 shrink-0 items-center justify-center rounded-full border border-[var(--line-dark)] text-ember"
                aria-hidden
              >
                <Icon name={a.icon} />
              </span>
              <span>
                <span className="block font-display text-lg leading-snug text-bone">
                  {a.title}
                </span>
                <span className="mt-1 block font-body text-[14px] leading-relaxed text-mist">
                  {a.detail}
                </span>
              </span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
