import type { Metadata, Viewport } from "next";
import { Cormorant, Hanken_Grotesk, JetBrains_Mono } from "next/font/google";
import { fetchSiteSettings } from "@/lib/content";
import JsonLd from "@/components/JsonLd";
import MotionProvider from "@/components/MotionProvider";
import { LocaleProvider } from "@/lib/i18n/LocaleContext";
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
import "./globals.css";

const display = Cormorant({
  subsets: ["latin"],
  // Only 300 (font-light) and the default 400 are used in the UI — dropping the
  // unused 500/600 weights removes 4 font files from the initial load.
  weight: ["300", "400"],
  style: ["normal", "italic"],
  variable: "--font-display",
  display: "swap",
});

const body = Hanken_Grotesk({
  subsets: ["latin"],
  weight: ["300", "400", "500"],
  variable: "--font-body",
  display: "swap",
});

const mono = JetBrains_Mono({
  subsets: ["latin"],
  weight: ["400", "500"],
  variable: "--font-mono",
  display: "swap",
});

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return {
    metadataBase: new URL(site.url),
    title: `${site.full} | Yoga, Fitness & Wellness, Lucknow`,
    description: `A yoga, fitness and wellness academy in Lucknow guided by ${site.founder}. Breath, movement and stillness — body and mind in balance.`,
    keywords: [
      "yoga Lucknow",
      "fitness Lucknow",
      "wellness academy",
      "therapeutic yoga",
      "pranayama",
      site.founder,
    ],
    alternates: { canonical: "/" },
    openGraph: {
      title: site.full,
      description: `Breath, movement and stillness. A yoga, fitness and wellness academy in Lucknow guided by ${site.founder}.`,
      url: site.url,
      siteName: site.full,
      type: "website",
      locale: "en_IN",
    },
    twitter: {
      card: "summary_large_image",
      title: site.full,
      description: `Breath, movement and stillness. A yoga, fitness and wellness academy in Lucknow guided by ${site.founder}.`,
    },
  };
}

export const viewport: Viewport = {
  themeColor: "#15161e",
  width: "device-width",
  initialScale: 1,
  colorScheme: "dark",
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const site = await fetchSiteSettings();

  return (
    <html
      lang="en-IN"
      className={`${display.variable} ${body.variable} ${mono.variable}`}
    >
      <body>
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[999] focus:bg-ember focus:px-4 focus:py-2 focus:font-mono focus:text-[12px] focus:uppercase focus:tracking-wide focus:text-void"
        >
          Skip to content
        </a>
        <JsonLd site={site} />
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
      </body>
    </html>
  );
}
