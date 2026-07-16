# ADR 0016 — Living Anatomy WebGL scene (delivery phasing)

| Field | Value |
|---|---|
| **Status** | Accepted (phased) |
| **Date** | 2026-07-09 |
| **Supersedes** | 0014 (retain-2D-canvas decision) — this ADR re-opens the question under D007, not reverses 0014's reasoning |
| **Context** | `07_SCENE_3D.md`, D002 (mesh sourcing), D007 (WebGL hero conditions) |

## Context

D007 approved a WebGL "Living Anatomy" figure as the homepage's cinematic centerpiece,
conditioned on: three+r3f loading AFTER LCP as a deferred chunk; a first-class 2D
silhouette tier for mobile/reduced-motion/no-WebGL/low-memory/save-data; Lighthouse
budgets enforced. This supersedes ADR 0014's "retain 2D canvas, don't integrate WebGL"
call — but only because D007 changes the *delivery contract* (deferred, gated, budgeted)
that made 0014 reject WebGL in the first place (bundle cost, no fallback, no budget gate).
0014's underlying data (bundle impact, GPU requirement, mobile performance) still holds;
D007 just adds the conditions under which paying that cost becomes acceptable.

## Decision

**Ship in two parts, sequenced by what's actually buildable right now.**

### Part 1 (this task, shipped) — `useBreathClock` + `SilhouetteTier`

- `components/scene/useBreathClock.ts`: the 4-4-6 pranayama clock, extracted verbatim
  from the old `BreathHero.tsx`, as one shared module-level instance (external store,
  not Context — same reasoning as 05's `useScrollProgress`: no Context Provider
  ancestor is guaranteed for every future consumer). Unit-tested against known t values.
- `components/scene/SilhouetteTier.tsx`: a seated meditation silhouette (two Path2D
  sub-paths — head + torso/crossed-legs), breath-scaled, with the existing glow rings
  and ember particles. Mounted in `Hero.tsx` unconditionally — this **is** the hero
  visual, not a loading placeholder, matching D007's "SilhouetteTier is first-class."

### Part 2 (deferred — PH-016) — `Scene`/`Figure`/`CameraRig`/`Lighting`

Not built in this task. Two concrete tooling gaps, not effort or difficulty:

1. **Mesh acquisition.** A license-clear candidate exists (CC-BY 4.0, "A Man Sitting",
   Sketchfab, 18k tris — see `DECISIONS.md` asset registry), found via web search in
   this task. But Sketchfab gates the actual binary download behind an authenticated
   account UI; no tool available in this environment can complete that download.
2. **Mesh processing + shader authoring.** Decimation, glTF export, and
   `gltf-transform`+Draco compression need Blender or the `gltf-transform` CLI —
   neither installed. Even with a processed mesh, authoring the custom fresnel-rim/
   emissive-flow-line shaders blind, with no 3D viewer to render and inspect the
   result, would be guessing at GLSL correctness rather than verifying it — the kind
   of unverifiable work this project's `verify-done` discipline exists to prevent.

07's own Step 1.5 anticipates exactly this outcome: *"IF no acceptable mesh found
after 5 candidates → do NOT stop the project: proceed with SilhouetteTier as the
shipped hero (it is first-class), add PH row 'figure mesh pending', continue to 08."*
One candidate was found (better than the zero the task file anticipates), but the
*processing* pipeline — not the sourcing — is what's actually blocked here. The same
graceful-degradation path applies: ship the tier that's real and verified, record
the gap, don't block the rest of the site on it.

## Consequences

- Homepage hero ships today, fully functional, in both themes, at every breakpoint,
  with no WebGL dependency and no bundle-budget risk (`/` first-load JS: 165 kB,
  +1 kB over the pre-07 baseline — see `STATUS.md`).
- `Figure`/`CameraRig`/`Lighting`/`Scene` remain unbuilt until PH-016 is resolved by
  a session with Blender/gltf-transform/an authenticated Sketchfab session available.
  `useBreathClock` and the `useScrollProgress` it will pair with (05) are already in
  place and ready to drive the camera rig once the mesh lands.
- No `three`/`@react-three/fiber`/`@react-three/drei` dependencies were added —
  `package.json` is unchanged by this task.

## Rollback strategy

Nothing to roll back — Part 2 was never started, so there's no WebGL code path to
disable. If PH-016 is later resolved, `Scene.tsx` mounts alongside `SilhouetteTier`
(crossfade on the shared breath clock, per D007) without touching `Hero.tsx`'s
existing SilhouetteTier mount.
