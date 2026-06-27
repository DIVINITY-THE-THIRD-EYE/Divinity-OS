import type { Metadata } from "next";
import { Cormorant, Hanken_Grotesk, JetBrains_Mono } from "next/font/google";
import { site } from "@/lib/content";
import JsonLd from "@/components/JsonLd";
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

export const metadata: Metadata = {
  metadataBase: new URL(site.url),
  title: "Divinity — The Third Eye | Yoga, Fitness & Wellness, Lucknow",
  description:
    "A yoga, fitness and wellness academy in Lucknow guided by Sachin Rajvanshi. Breath, movement and stillness — body and mind in balance.",
  keywords: [
    "yoga Lucknow",
    "fitness Lucknow",
    "wellness academy",
    "therapeutic yoga",
    "pranayama",
    "Sachin Rajvanshi",
  ],
  alternates: { canonical: "/" },
  openGraph: {
    title: "Divinity — The Third Eye",
    description:
      "Breath, movement and stillness. A yoga, fitness and wellness academy in Lucknow.",
    url: site.url,
    siteName: "Divinity — The Third Eye",
    type: "website",
    locale: "en_IN",
  },
  twitter: {
    card: "summary_large_image",
    title: "Divinity — The Third Eye",
    description:
      "Breath, movement and stillness. A yoga, fitness and wellness academy in Lucknow.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${display.variable} ${body.variable} ${mono.variable}`}
    >
      <body className="has-custom-cursor">
        <a
          href="#main-content"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[999] focus:bg-ember focus:px-4 focus:py-2 focus:font-mono focus:text-[12px] focus:uppercase focus:tracking-wide focus:text-void"
        >
          Skip to content
        </a>
        <JsonLd />
        {children}
      </body>
    </html>
  );
}
