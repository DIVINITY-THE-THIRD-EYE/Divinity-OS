# 07 — 3D SCENE (Living Anatomy figure)

## PURPOSE
The approved 3D centerpiece: luminous meditating figure in one continuous scene, camera
driven by the scroll story. Desktop-fine-pointer experience. Everything else gets the
2D silhouette tier.

## INPUTS
- `05` COMPLETE (`useScrollProgress()`), `03` COMPLETE (theme presets), D002, D007.
- Breath clock: extract from old `BreathHero.tsx` → `components/scene/useBreathClock.ts`
  (inhale 4 · hold 4 · exhale 6, easeInOut — reuse the existing `breathAt` function verbatim).

## STEP 1 — MESH SOURCING (research; may run any time after Phase 1)
1. Find a CC0 / CC-BY / purchasable-license human meditation/anatomy base mesh.
   Search order: Sketchfab (filter: downloadable, CC0/CC-BY), Quaternius, Polyhaven,
   Z-Anatomy (CC-BY-SA-2.1 — note share-alike implication), TurboSquid (royalty-free license).
   Requirement: seated/cross-legged pose OR riggable neutral pose; humanoid; no textures needed
   (we shade procedurally).
2. VERIFY LICENSE (mandatory): license must permit commercial web use + modification.
   CC-BY → attribution goes in site footer/colophon + DECISIONS asset registry.
   CC-BY-SA on a MESH → acceptable (share-alike binds the mesh, not the site) but record reasoning.
   Unverifiable license → do not download. Try next candidate.
3. Record in `DECISIONS.md` → Asset registry: URL, license, date, author.
4. Process: decimate to 30–50k tris → export glTF → `gltf-transform optimize` with Draco
   → target ≤1.2 MB. Store at `website/public/models/figure.glb`.
5. **IF no acceptable mesh found after 5 candidates** → do NOT stop the project: proceed
   with `SilhouetteTier` as the shipped hero (it is first-class), add PH row
   "figure mesh pending", continue to 08. The scene lands later without blocking launch.

## STEP 2 — DEPENDENCIES
`npm i three @react-three/fiber @react-three/drei` (drei: selective imports only).
NO postprocessing package (glow = emissive materials + additive sprites).
Record versions in DECISIONS Implementation notes.

## STEP 3 — COMPONENTS (`website/components/scene/`)
| File | Contract |
|---|---|
| `useBreathClock.ts` | shared 4-4-6 clock; drives scene, silhouette, hero readout — ONE clock instance via context |
| `SilhouetteTier.tsx` | 2D canvas figure: seated silhouette (SVG path drawn to canvas), breath-scaled chest, ember particles from old BreathHero (reuse that code), ~3 kB. THIS is the hero visual for: mobile/coarse pointer, `prefers-reduced-motion` (static frame), no WebGL2, `navigator.deviceMemory <= 4`, save-data, and while the 3D chunk loads |
| `Scene.tsx` | `next/dynamic` import, `ssr:false`, loaded via `requestIdleCallback` AFTER window `load` event. r3f `<Canvas frameloop="demand">`, `PerformanceMonitor` adaptive DPR (floor 1), WebGL context-loss → unmount to SilhouetteTier |
| `Figure.tsx` | loads `figure.glb`; material = custom fresnel-rim translucent shader + emissive UV-scrolled flow-lines; breath = vertex displacement on chest region driven by clock uniform |
| `CameraRig.tsx` | consumes `useScrollProgress()`; keyframes: orbit (act I) → push toward sternum (act II) → rise + recede (act III); pointer lean lerped quaternion ±4° |
| `Lighting.tsx` | two presets (night: ember key + emerald ambient; day: gold key + beige ambient) matching `data-theme`; theme change lerps uniforms 800ms |

## DELIVERY RULES (D007 — hard)
- LCP frame = DOM H1 + SilhouetteTier. 3D chunk NEVER in route's blocking bundle
  (verify with `next build` output: page first-load JS unchanged ±5 kB).
- Crossfade Scene over Silhouette on the SAME breath phase (shared clock) — no visual jump.
- Copy/DOM always above canvas; canvas `aria-hidden`, `pointer-events:none`.

## FILES ALLOWED
`website/components/scene/**` (new) · `components/home/Hero.tsx` (mount tiers) ·
`package.json` (three deps) · `public/models/**` · `design/adr/0016-webgl-scene.md` (new) ·
STATUS/CHANGELOG/DECISIONS/PLACEHOLDERS.

## FILES FORBIDDEN
Everything else. Especially: no edits to ScrollScore contract, no postprocessing deps.

## STEPS (build order)
1. `useBreathClock` + unit test (phase values at t=0,4,8,14 match old `breathAt`).
2. `SilhouetteTier` — mount in Hero for ALL users. Validate (this alone = shippable hero).
3. Deps install. `Scene` shell with deferred load + device gating + context-loss fallback.
4. `Figure` with placeholder geometry (drei `<Sphere>`) to prove the pipeline, then swap
   real mesh when Step-1 asset lands.
5. `CameraRig` + `Lighting`, wired to scroll progress + theme.
6. Fallback matrix manual QA (see VALIDATION).

## VALIDATION
- Standard block.
- `next build` route table: `/` first-load JS within +5 kB of pre-task value. Record numbers.
- Fallback matrix (each row must be observed, not assumed):
  desktop fine-pointer WebGL → full scene · mobile emulation → silhouette only, no three
  chunk in network log · reduced-motion → static silhouette frame · WebGL disabled
  (`--disable-webgl` or override) → silhouette · mid-scroll context loss (devtools) → silhouette, no crash.
- Lighthouse (see 15 for method): desktop ≥95 with scene, mobile ≥90 (mobile never loads scene).

## IF VALIDATION FAILS
- Budget blown → chunk is in the blocking path; check the dynamic import has `ssr:false`
  and no top-level import of `three` anywhere in server-reachable modules.
- FPS poor on test hardware → reduce DPR floor branch, halve particle counts, simplify
  flow-line shader; NEVER add more effects to compensate.

## CHECKPOINT
Commit: `feat(rebuild): 07 living-anatomy scene — figure, camera rig, fallback tiers`
Write ADR 0016 (supersedes 0014, records D007 conditions).

## STOP CONDITION
Phase 4 gate. Gate report with build numbers + fallback matrix results + rebase →
auto-continue (D011).

## NEXT
`08_CORE_PAGES.md`
