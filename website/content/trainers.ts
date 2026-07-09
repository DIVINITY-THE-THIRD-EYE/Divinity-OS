// Trainer roster. Add real teachers here as bios are confirmed — the Trainers
// page renders whatever exists and shows an empty state for the rest, never
// fabricated entries.

import { founder } from "./founder";

export type Trainer = {
  name: string;
  role: string;
  image?: string;
  bio: string;
  focus?: string[];
};

// TODO(PH-003): additional trainer profiles pending — confirm identities + rights
// for the public/guru/ photos before adding more entries.
export const trainers: Trainer[] = [
  {
    name: founder.name,
    role: founder.title,
    image: founder.image,
    bio: founder.bio,
    focus: ["Hatha & Vinyasa", "Pranayama", "Therapeutic yoga"],
  },
];
