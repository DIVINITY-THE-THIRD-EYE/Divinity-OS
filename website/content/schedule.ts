// Display copy for the weekly schedule. TODO(PH-008): the app's `batches`
// table in Supabase is the operationally authoritative source — decide
// whether this stays static marketing copy or becomes a live fetch.

export type ClassSlot = {
  time: string;
  batch: "Dawn" | "Midday" | "Dusk";
  name: string;
  detail: string;
  level: string;
};

export const schedule: Record<string, ClassSlot[]> = {
  Mon: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Strength Training", detail: "Resistance work", level: "All levels" },
  ],
  Tue: [
    { time: "6:00", batch: "Dawn", name: "Vinyasa Flow", detail: "Dynamic sequence", level: "Intermediate" },
    { time: "18:30", batch: "Dusk", name: "Pranayama", detail: "Breath & meditation", level: "Open" },
  ],
  Wed: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Conditioning", detail: "Endurance circuit", level: "All levels" },
  ],
  Thu: [
    { time: "6:00", batch: "Dawn", name: "Vinyasa Flow", detail: "Dynamic sequence", level: "Intermediate" },
    { time: "18:30", batch: "Dusk", name: "Power Yoga", detail: "Strength & heat", level: "All levels" },
  ],
  Fri: [
    { time: "6:00", batch: "Dawn", name: "Hatha Yoga", detail: "Asana & breath", level: "All levels" },
    { time: "11:00", batch: "Midday", name: "Therapeutic Yoga", detail: "Recovery focus", level: "By appt" },
    { time: "18:30", batch: "Dusk", name: "Mobility", detail: "Joints & flexibility", level: "All levels" },
  ],
  Sat: [
    { time: "6:00", batch: "Dawn", name: "Meditation & Pranayama", detail: "Stillness practice", level: "Open" },
    { time: "18:30", batch: "Dusk", name: "Community Workshop", detail: "Rotating theme", level: "Open" },
  ],
};
