// Lightweight bilingual (English/Hindi) support for the site's global chrome
// (Nav, Footer). English strings are the source of truth (lib/nav.ts,
// component copy); Hindi is a display-layer lookup keyed by the English
// string, so lib/nav.ts stays the single source of truth for routes/labels.
//
// Scope note: this covers Nav + Footer + the homepage hero only, not full
// page-by-page content translation across the site — see PROJECT decisions
// for the full-site i18n follow-up. Locale is a client-side preference
// (localStorage), not URL-routed (no /en/, /hi/ prefixes), matching how the
// Flutter app's language switcher also works in-place.

export type Locale = "en" | "hi";

export const locales: Locale[] = ["en", "hi"];

const hi: Record<string, string> = {
  About: "परिचय",
  Founder: "संस्थापक",
  Programs: "कार्यक्रम",
  Services: "सेवाएं",
  Schedule: "समय सारणी",
  Pricing: "मूल्य",
  Membership: "सदस्यता",
  Trainers: "प्रशिक्षक",
  Gallery: "गैलरी",
  Blog: "ब्लॉग",
  Events: "आयोजन",
  Testimonials: "प्रशंसापत्र",
  FAQ: "सामान्य प्रश्न",
  Contact: "संपर्क करें",
  "Privacy Policy": "गोपनीयता नीति",
  "Terms & Conditions": "नियम और शर्तें",
  Practice: "अभ्यास",
  Academy: "अकादमी",
  Begin: "शुरू करें",
  Menu: "मेनू",
  Close: "बंद करें",
  "Contact & enquire": "संपर्क करें",
  "Visit & connect": "मिलें और जुड़ें",
  Instagram: "इंस्टाग्राम",
  WhatsApp: "व्हाट्सएप",
  Language: "भाषा",
};

const dictionaries: Record<Locale, Record<string, string>> = { en: {}, hi };

export function translate(locale: Locale, text: string): string {
  if (locale === "en") return text;
  return dictionaries[locale][text] ?? text;
}
