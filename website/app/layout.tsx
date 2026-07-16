import type { Metadata, Viewport } from "next";
import Script from "next/script";
import { Nunito, DM_Sans } from "next/font/google";
import { fetchSiteSettings } from "@/lib/content";
import { routeOverrides } from "@/content/seo";
import JsonLd from "@/components/JsonLd";
import { ThemeProvider } from "@/lib/theme/ThemeContext";
import "./globals.css";

// Display = Nunito (rounded terminals carry the clay personality on headings,
// stat numbers, emphasis). 700/800/900 cover bold → black display weights.
const display = Nunito({
  subsets: ["latin"],
  weight: ["700", "800", "900"],
  variable: "--font-display",
  display: "swap",
});

// Body = DM Sans (geometric, highly legible) for all UI text. The clay/neu
// system has no monospace role, so --font-mono aliases to this in Tailwind;
// eyebrows are DM Sans 700 uppercase (see .eyebrow in globals.css).
const body = DM_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "700"],
  variable: "--font-body",
  display: "swap",
});

export async function generateMetadata(): Promise<Metadata> {
  const site = await fetchSiteSettings();
  return {
    metadataBase: new URL(site.url),
    title: `${site.full} | Yoga, Fitness & Wellness, Lucknow`,
    description: `A yoga, fitness and wellness academy in Lucknow guided by ${site.founder}. Breath, movement and stillness — body and mind in balance.`,
    // Single source of truth for homepage keywords lives in content/seo.ts
    // (D005 — never hardcode); site.founder is appended since it's a live
    // fact, not an editorial keyword choice.
    keywords: [...(routeOverrides.find((r) => r.path === "/")?.keywords ?? []), site.founder],
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
  colorScheme: "light",
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
      suppressHydrationWarning
      className={`${display.variable} ${body.variable}`}
    >
      <body>
        {/* No-flash theme script: sets data-theme before first paint so CSS
            never renders the wrong theme on a hard reload. Reads the same
            localStorage key as ThemeContext; strategy="beforeInteractive"
            makes Next.js inline this in <head>, ahead of hydration. */}
        <Script id="theme-init" strategy="beforeInteractive">
          {`(function(){try{var t=localStorage.getItem('divinity_theme');if(t!=='light'&&t!=='dark'){t='light';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();`}
        </Script>
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[999] focus:bg-ember focus:px-4 focus:py-2 focus:font-mono focus:text-[12px] focus:uppercase focus:tracking-wide focus:text-void"
        >
          Skip to content
        </a>
        <JsonLd site={site} />
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  );
}
