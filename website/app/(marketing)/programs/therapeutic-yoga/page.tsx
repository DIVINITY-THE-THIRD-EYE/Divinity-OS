import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { pageMeta, absUrl, buildCourseJsonLd } from "@/lib/seo";
import { disciplines, fetchSiteSettings } from "@/lib/content";
import ProgramDetail from "@/components/pages/ProgramDetail";

const DISCIPLINE_TITLE = "Therapeutic Yoga";

export async function generateMetadata(): Promise<Metadata> {
  const d = disciplines.find((x) => x.title === DISCIPLINE_TITLE);
  return pageMeta({
    title: d?.title ?? DISCIPLINE_TITLE,
    description: d?.longDescription ?? d?.description ?? "",
    path: "/programs/therapeutic-yoga",
  });
}

export default async function TherapeuticYogaPage() {
  const d = disciplines.find((x) => x.title === DISCIPLINE_TITLE);
  if (!d) notFound();

  const site = await fetchSiteSettings();

  const jsonLd = buildCourseJsonLd({
    name: d.title,
    description: d.longDescription ?? d.description,
    url: absUrl("/programs/therapeutic-yoga"),
    providerName: site.full,
    providerUrl: absUrl("/"),
  });

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <ProgramDetail discipline={d} city={site.city} />
    </>
  );
}
