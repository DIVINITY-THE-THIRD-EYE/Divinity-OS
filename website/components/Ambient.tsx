// Ambient clay layer: soft floating colour blobs that drift behind the glass
// surfaces (the candy-shop lighting of the clay system) + a faint grain.
// Motion lives in globals.css and is disabled under prefers-reduced-motion.
// pointer-events-none + negative z so it never intercepts interaction.
export default function Ambient() {
  return (
    <>
      <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden" aria-hidden>
        <div className="clay-float absolute -left-[10%] -top-[10%] h-[55vh] w-[55vh] rounded-full bg-accent/15 blur-3xl" />
        <div className="clay-float-delayed animation-delay-2000 absolute -right-[12%] top-[15%] h-[50vh] w-[50vh] rounded-full bg-accent-2/[0.12] blur-3xl" />
        <div className="clay-float-slow animation-delay-4000 absolute bottom-[-10%] left-[30%] h-[50vh] w-[50vh] rounded-full bg-[#0EA5E9]/[0.12] blur-3xl" />
      </div>
      {/* Act-break glow — opacity driven by data-act on <html> (ScrollScore) */}
      <div className="ambient" aria-hidden />
      <div className="grain" aria-hidden />
    </>
  );
}
