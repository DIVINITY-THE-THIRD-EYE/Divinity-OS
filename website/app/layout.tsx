import type { Metadata, Viewport } from "next";
import Script from "next/script";
import { Cormorant, Hanken_Grotesk, JetBrains_Mono } from "next/font/google";
import { fetchSiteSettings } from "@/lib/content";
import { routeOverrides } from "@/content/seo";
import JsonLd from "@/components/JsonLd";
import { ThemeProvider } from "@/lib/theme/ThemeContext";
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
  // globals.css sets `body { font-weight: 300 }` site-wide and no component
  // ever overrides it (grep-verified: zero font-medium/semibold/bold usage
  // paired with font-body) — 400/500 were dead weight (15_PERFORMANCE.md).
  weight: ["300"],
  variable: "--font-body",
  display: "swap",
});

const mono = JetBrains_Mono({
  subsets: ["latin"],
  // Only 400 renders in practice: nothing requests mono text at 500
  // (grep-verified), and the body's inherited 300 request falls back to
  // the nearest loaded weight (400) per the CSS font-matching algorithm.
  weight: ["400"],
  variable: "--font-mono",
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
      suppressHydrationWarning
      className={`${display.variable} ${body.variable} ${mono.variable}`}
    >
      <body>
        {/* No-flash theme script: sets data-theme before first paint so CSS
            never renders the wrong theme on a hard reload. Reads the same
            localStorage key as ThemeContext; strategy="beforeInteractive"
            makes Next.js inline this in <head>, ahead of hydration. */}
        <Script id="theme-init" strategy="beforeInteractive">
          {`(function(){try{var t=localStorage.getItem('divinity_theme');if(t!=='light'&&t!=='dark'){t=window.matchMedia('(prefers-color-scheme: light)').matches?'light':'dark';}document.documentElement.setAttribute('data-theme',t);}catch(e){}})();`}
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
