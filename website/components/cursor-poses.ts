// 12 Surya Namaskar (Sun Salutation) poses for YogaCursor, as simple stick-
// figure silhouettes (head circle + one stroke path per pose for torso/limbs).
//
// FALLBACK TAKEN (per 06_YOGA_CURSOR.md's own escape hatch): hand-authoring 12
// complex paths with an IDENTICAL command/point sequence (required for numeric
// point-by-point lerp morphing) isn't something this model can do reliably
// without a visual editor — the "critical for a weak model" warning in the
// task file exists precisely because that's failure-prone. Poses crossfade
// (opacity swap) at segment boundaries instead of morphing. See DECISIONS.md.
//
// Each pose is deliberately simple/iconographic — this renders at cursor
// scale (~28px), where fine anatomical detail is invisible anyway. viewBox is
// 0 0 100 100 for all; head is a separate <circle> so only the body path
// varies per pose.

export type CursorPose = {
  name: string;
  head: { cx: number; cy: number; r: number };
  body: string; // single stroke path, M/L only
};

export const CURSOR_POSES: CursorPose[] = [
  {
    // 1. Pranamasana — standing, palms together at chest
    name: "Pranamasana",
    head: { cx: 50, cy: 16, r: 6 },
    body: "M50,22 L50,56 M50,30 L44,36 L50,33 L56,36 Z M50,56 L42,92 M50,56 L58,92",
  },
  {
    // 2. Hasta Uttanasana — standing, arms raised overhead, gentle back bend
    name: "Hasta Uttanasana",
    head: { cx: 51, cy: 15, r: 6 },
    body: "M51,21 L50,56 M50,26 L36,8 M50,26 L64,8 M50,56 L42,92 M50,56 L58,92",
  },
  {
    // 3. Padahastasana — standing forward fold, hands toward feet
    name: "Padahastasana",
    head: { cx: 62, cy: 60, r: 6 },
    body: "M62,66 L52,48 L52,20 M52,48 L34,58 M52,20 L38,10 M52,20 L66,10 M34,58 L30,92",
  },
  {
    // 4. Ashwa Sanchalanasana — equestrian lunge, right leg forward
    name: "Ashwa Sanchalanasana",
    head: { cx: 46, cy: 30, r: 6 },
    body: "M46,36 L48,58 M48,58 L30,50 M48,58 L72,50 M30,50 L20,50 M72,50 L82,80 M46,36 L36,20 M46,36 L58,22",
  },
  {
    // 5. Dandasana — plank, body one straight line
    name: "Dandasana",
    head: { cx: 20, cy: 46, r: 6 },
    body: "M20,52 L82,58 M40,50 L34,30 M40,50 L46,68 M64,54 L70,34 M64,54 L60,72",
  },
  {
    // 6. Ashtanga Namaskara — eight-limbed, chest and knees to the floor
    name: "Ashtanga Namaskara",
    head: { cx: 22, cy: 64, r: 6 },
    body: "M22,70 L78,66 M36,68 L30,50 M60,67 L66,48 M50,68 L48,80 L38,84 M50,68 L58,82 L68,84",
  },
  {
    // 7. Bhujangasana — cobra, chest lifted, hips low
    name: "Bhujangasana",
    head: { cx: 24, cy: 40, r: 6 },
    body: "M24,46 L40,58 L74,64 M40,58 L34,42 M34,42 L44,32 M60,62 L82,54 M60,62 L82,70",
  },
  {
    // 8. Adho Mukha Svanasana — downward dog, inverted V
    name: "Adho Mukha Svanasana",
    head: { cx: 50, cy: 66, r: 6 },
    body: "M50,60 L28,40 L18,38 M50,60 L72,40 L82,38 M50,60 L44,86 L36,92 M50,60 L56,86 L64,92",
  },
  {
    // 9. Ashwa Sanchalanasana — equestrian lunge, mirrored (left leg forward)
    name: "Ashwa Sanchalanasana (L)",
    head: { cx: 54, cy: 30, r: 6 },
    body: "M54,36 L52,58 M52,58 L70,50 M52,58 L28,50 M70,50 L80,50 M28,50 L18,80 M54,36 L64,20 M54,36 L42,22",
  },
  {
    // 10. Padahastasana — forward fold (return)
    name: "Padahastasana (return)",
    head: { cx: 38, cy: 60, r: 6 },
    body: "M38,66 L48,48 L48,20 M48,48 L66,58 M48,20 L62,10 M48,20 L34,10 M66,58 L70,92",
  },
  {
    // 11. Hasta Uttanasana — raised arms (return)
    name: "Hasta Uttanasana (return)",
    head: { cx: 49, cy: 15, r: 6 },
    body: "M49,21 L50,56 M50,26 L64,8 M50,26 L36,8 M50,56 L58,92 M50,56 L42,92",
  },
  {
    // 12. Pranamasana — prayer pose (return to start)
    name: "Pranamasana (return)",
    head: { cx: 50, cy: 16, r: 6 },
    body: "M50,22 L50,56 M50,30 L44,36 L50,33 L56,36 Z M50,56 L58,92 M50,56 L42,92",
  },
];
