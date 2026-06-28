import { site } from "./content";

/**
 * Build a WhatsApp click-to-chat URL. Centralised so the number, encoding, and
 * (future) tracking params live in one place instead of being rebuilt in every
 * CTA component.
 */
export function waHref(message?: string): string {
  const base = `https://wa.me/${site.whatsapp}`;
  return message ? `${base}?text=${encodeURIComponent(message)}` : base;
}
