// Server-safe ambient layers: breathing gradient + film grain.
// Animation lives in globals.css (and is disabled for reduced motion).
export default function Ambient() {
  return (
    <>
      <div className="ambient" aria-hidden />
      <div className="grain" aria-hidden />
    </>
  );
}
