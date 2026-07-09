// Per-route SEO overrides. Not yet wired into lib/seo.ts's pageMeta() (each
// page currently passes its own title/description) — populated fully in
// 14_SEO.md. One entry keeps this module non-empty and typed until then.

export type RouteSeo = {
  path: string;
  title?: string;
  description?: string;
  keywords?: string[];
};

export const routeOverrides: RouteSeo[] = [
  { path: "/", keywords: ["yoga Lucknow", "fitness academy Lucknow", "Divinity"] },
];
