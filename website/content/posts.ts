// CMS-ready. Staging placeholders by design — the /blog routes render an
// empty state in production until real articles replace these.

export type Post = {
  slug: string;
  title: string;
  excerpt: string;
  body: string;
  date: string; // ISO
  author: string;
  cover?: string;
  tags?: string[];
};

// TODO(PH-012): replace with real articles before launch; blog stays noindex
// until then (see PLACEHOLDERS.md BD-003).
export const posts: Post[] = [
  {
    slug: "science-of-prana-why-breath-comes-first",
    title: "[STAGING] Science of Prana & Breathwork",
    excerpt: "[STAGING CONTENT] This is a staging placeholder article explaining the physiological benefits of breathwork. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the breathing science article. The public marketing site renders this from the local staging model when Sanity CMS is offline, and overrides it when online. Replace this with a real article on Hatha/Pranayama before going live.",
    date: "2026-06-28",
    author: "Sachin Rajvanshi",
  },
  {
    slug: "strength-meets-stillness-balancing-yoga-and-fitness",
    title: "[STAGING] Strength Meets Stillness in Practice",
    excerpt: "[STAGING CONTENT] Staging article exploring the balance of yoga flow and progressive resistance training. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the strength and stillness article. In production, this article description is fetched from Sanity CMS. Replace this staging event before going live.",
    date: "2026-06-25",
    author: "Sachin Rajvanshi",
  },
  {
    slug: "guided-recovery-how-therapeutic-yoga-heals",
    title: "[STAGING] Guided Recovery & Therapeutic Alignment",
    excerpt: "[STAGING CONTENT] Staging article on supported postures and gentle restorative practices. Replace this in Sanity CMS.",
    body: "[STAGING CONTENT] This is placeholder text for the therapeutic recovery article. In production, this article description is fetched from Sanity CMS. Replace this staging event before going live.",
    date: "2026-06-20",
    author: "Sachin Rajvanshi",
  },
];

export const getPostBySlug = (slug: string) => posts.find((p) => p.slug === slug);
