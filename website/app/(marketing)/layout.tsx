import { fetchSiteSettings } from "@/lib/content";
import { LocaleProvider } from "@/lib/i18n/LocaleContext";
import MotionProvider from "@/components/MotionProvider";
import Ambient from "@/components/Ambient";
import ScrollProgress from "@/components/ScrollProgress";
import SmoothScroll from "@/components/SmoothScroll";
import Cursor from "@/components/Cursor";
import CommandPalette from "@/components/CommandPalette";
import PromoBar from "@/components/PromoBar";
import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import WhatsAppFab from "@/components/WhatsAppFab";
import StickyCta from "@/components/StickyCta";

/**
 * Marketing chrome (Lenis/scroll, cursor, nav, footer, CTAs) lives here — not
 * the root layout — so the student portal (added in 12/13) never pays for it
 * (E-002, 00_MASTER_EXECUTION ARCHITECTURE BASELINE).
 */
export default async function MarketingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const site = await fetchSiteSettings();

  return (
    <LocaleProvider>
      <MotionProvider>
        <Ambient />
        <ScrollProgress />
        <SmoothScroll />
        <Cursor />
        <CommandPalette site={site} />
        <PromoBar />
        <Nav site={site} />
        <main id="main-content" tabIndex={-1} className="outline-none">
          {children}
        </main>
        <Footer site={site} />
        <WhatsAppFab site={site} />
        <StickyCta site={site} />
      </MotionProvider>
    </LocaleProvider>
  );
}
