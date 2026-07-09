/**
 * Minimal portal layout — no Lenis/cursor/Nav/Footer/marketing providers
 * (E-002, 00_MASTER_EXECUTION architecture baseline). The student portal is
 * a different product sharing the domain; it shouldn't pay for marketing JS.
 */
export default function PortalLayout({ children }: { children: React.ReactNode }) {
  return (
    <main id="main-content" tabIndex={-1} className="min-h-screen bg-surface outline-none">
      {children}
    </main>
  );
}
