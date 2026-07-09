import PreviewSection from "@/components/layout/PreviewSection";
import Gallery from "@/components/Gallery";

/** Act III, section 7 — 6-image teaser; depth treatment lands in 05_MOTION_SCROLLSTORY.md. */
export default function GalleryPreview() {
  return (
    <PreviewSection
      eyebrow="The space"
      title="Where the practice"
      titleAccent="lives."
      cta={{ href: "/gallery", label: "Enter the space" }}
    >
      <Gallery limit={6} showHeading={false} />
    </PreviewSection>
  );
}
