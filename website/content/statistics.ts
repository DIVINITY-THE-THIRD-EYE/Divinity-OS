// "Academy at a glance" figures. Not yet wired into StatsBand (which currently
// derives its own counts from programs.ts/schedule.ts) — real, verified
// numbers need business sign-off first.

export type StatItem = {
  value: number;
  label: string;
  verified: boolean;
};

// TODO(PH-004): real member statistics need business sign-off — no fabricated
// figures until confirmed.
export const statistics: StatItem[] = [
  {
    value: 0,
    label: "[PLACEHOLDER: verified member count — see PLACEHOLDERS.md PH-004]",
    verified: false,
  },
];
