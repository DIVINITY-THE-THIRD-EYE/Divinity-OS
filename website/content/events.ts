// CMS-ready. Staging placeholders by design — the /events routes render an
// empty state in production until real events replace these. stripStaging()
// (lib/staging.ts) enforces that: staging entries survive only when
// NEXT_PUBLIC_SHOW_STAGING=1, so production visitors never see "[STAGING]".

import { stripStaging } from "@/lib/staging";

export type EventItem = {
  slug: string;
  title: string;
  summary: string;
  body: string;
  date: string; // ISO start
  endDate?: string;
  location: string;
  cover?: string;
};

// TODO(PH-011): replace with real, upcoming events before launch.
const stagingEvents: EventItem[] = [
  {
    slug: "weekend-pranayama-intensive",
    title: "[STAGING] Weekend Pranayama Workshop",
    summary: "[STAGING CONTENT] Staging intensive focusing on breathing techniques. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the weekend pranayama workshop. In production, this workshop description is fetched from Sanity CMS. Replace this staging event before going live.",
    date: "2026-07-18T07:30:00Z",
    endDate: "2026-07-19T09:30:00Z",
    location: "Lucknow Studio (Staging)",
  },
  {
    slug: "joint-mobility-and-restorative-yoga",
    title: "[STAGING] Joint Mobility & Restorative Yoga",
    summary: "[STAGING CONTENT] Staging workshop focusing on joint release and alignment. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the joint mobility workshop. In production, this workshop description is fetched from Sanity CMS. Replace this staging event before going live.",
    date: "2026-07-25T16:00:00Z",
    endDate: "2026-07-25T18:30:00Z",
    location: "Lucknow Studio (Staging)",
  },
  {
    slug: "community-satsang-and-guided-meditation",
    title: "[STAGING] Community Satsang & Guided Meditation",
    summary: "[STAGING CONTENT] Staging monthly gathering for philosophy and meditation. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the community Satsang. In production, this event description is fetched from Sanity CMS. Replace this staging event before going live.",
    date: "2026-08-08T18:00:00Z",
    endDate: "2026-08-08T19:30:00Z",
    location: "Lucknow Studio (Staging)",
  },
];

export const events: EventItem[] = stripStaging(stagingEvents, ["title", "summary"]);

export const getEventBySlug = (slug: string) => events.find((e) => e.slug === slug);

/** Upcoming events, soonest first (today onward). */
export const upcomingEvents = () => {
  const now = Date.now();
  return events
    .filter((e) => new Date(e.date).getTime() >= now)
    .sort((a, b) => +new Date(a.date) - +new Date(b.date));
};
