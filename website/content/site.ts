// Core site identity. See content/contact.ts, content/social.ts and
// content/founder.ts for the data this used to be flattened with in lib/content.ts.

import { founder } from "./founder";

export const site = {
  name: "Divinity",
  full: "Divinity — The Third Eye",
  city: "Lucknow, Uttar Pradesh",
  entity: "Amaratv Krishi LLP",
  est: "2024",
  url: "https://staging.divinitytte.com", // ← clearly identified staging domain
  // Brand marks (see public/brand)
  logoMark: "/brand/logo-mark.png", // ember lotus, transparent — for dark surfaces
  logoFull: "/brand/logo-full.png", // full lockup with wordmark — for light surfaces
  founderName: founder.name,
};
