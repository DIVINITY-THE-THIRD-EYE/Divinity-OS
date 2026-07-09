// Single source of truth for site navigation — consumed by the Nav, Footer,
// command palette and sitemap so routes never drift out of sync.

export type NavItem = { href: string; label: string; primary?: boolean };

export const navItems: NavItem[] = [
  { href: "/about", label: "About", primary: true },
  { href: "/programs", label: "Programs", primary: true },
  { href: "/schedule", label: "Schedule", primary: true },
  { href: "/pricing", label: "Pricing", primary: true },
  { href: "/trainers", label: "Trainers", primary: true },
  { href: "/founder", label: "Founder" },
  { href: "/gallery", label: "Gallery" },
  { href: "/blog", label: "Blog" },
  { href: "/events", label: "Events" },
  { href: "/contact", label: "Contact" },
];

export const primaryNav = navItems.filter((i) => i.primary);

export const legalItems: NavItem[] = [
  { href: "/privacy", label: "Privacy Policy" },
  { href: "/terms", label: "Terms & Conditions" },
];

/** Footer link groups. */
export const footerGroups: { title: string; items: NavItem[] }[] = [
  {
    title: "Practice",
    items: [
      { href: "/programs", label: "Programs" },
      { href: "/schedule", label: "Schedule" },
      { href: "/pricing", label: "Pricing" },
      { href: "/trainers", label: "Trainers" },
    ],
  },
  {
    title: "Academy",
    items: [
      { href: "/about", label: "About" },
      { href: "/founder", label: "Founder" },
      { href: "/gallery", label: "Gallery" },
      { href: "/blog", label: "Blog" },
      { href: "/events", label: "Events" },
      { href: "/contact#faq", label: "FAQ" },
    ],
  },
];
