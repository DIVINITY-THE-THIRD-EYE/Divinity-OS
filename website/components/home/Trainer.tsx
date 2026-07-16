import PreviewSection from "@/components/layout/PreviewSection";
import TrainerCard from "@/components/cards/TrainerCard";
import { trainers } from "@/content/trainers";

/** Act II, section 5 — founder + guru photos; placeholder-labeled bios are fine. */
export default function Trainer() {
  return (
    <PreviewSection
      eyebrow="Who guides you"
      title="Taught by"
      titleAccent="hand."
      cta={{ href: "/trainers", label: "Meet the team" }}
    >
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {trainers.slice(0, 3).map((t) => (
          <TrainerCard key={t.name} t={t} />
        ))}
      </div>
    </PreviewSection>
  );
}
