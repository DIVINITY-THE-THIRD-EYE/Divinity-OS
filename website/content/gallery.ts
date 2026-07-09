// The space & the practice — real photography from the academy in Lucknow.
// Images live in public/studio and public/guru. width/height are the source
// dimensions so next/image reserves space (no layout shift).

export type GalleryShot = {
  src: string;
  alt: string;
  w: number;
  h: number;
  caption?: string;
  rights?: string;
};

// TODO(PH-015): confirm publication rights for public/studio/ photos.
export const studioGallery: GalleryShot[] = [
  { src: "/studio/yc_18.webp", alt: "The practice hall, set beneath the studio's lotus emblem", w: 6000, h: 4000 },
  { src: "/studio/yc_8.webp", alt: "The lamp-lit entrance to Divinity in Lucknow", w: 4000, h: 6000 },
  { src: "/guru/guru_9.webp", alt: "A bound headstand, held with control before the class", w: 1141, h: 1141 },
  { src: "/studio/yc_24.webp", alt: "Reception — where every visit to the academy begins", w: 4000, h: 6000 },
  { src: "/studio/yc_12.webp", alt: "Mats rolled and ready for the next breath", w: 6000, h: 4000 },
  { src: "/guru/guru_5.webp", alt: "Rooted in lineage — the asana as it has long been taught", w: 1140, h: 895 },
  { src: "/studio/yc_10.webp", alt: "A corner of calm — water, shrine and props for therapeutic work", w: 6000, h: 4000 },
  { src: "/studio/yc_5.webp", alt: "Blocks, bolsters and props for supported practice", w: 4000, h: 6000 },
];
