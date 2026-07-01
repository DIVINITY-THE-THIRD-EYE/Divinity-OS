# Original User Request

## Initial Request — 2026-06-30T22:02:13+05:30

Make the Next.js website (located at `divinity-third-eye/divinity/`) premium, production-complete, and highly polished, featuring realistic Divinity business data, smooth progressive animations, a technical evaluation of WebGL vs 2D canvas, CMS dynamic data support, and comprehensive automated test verification.

Working directory: c:\Users\PC\OneDrive\Documents\Divinity TTE\divinity-third-eye\divinity
Integrity mode: development

## Overall Objective

The objective is not simply to improve the website. The objective is to produce a production-ready marketing website for Divinity TTE that is ready for public launch and capable of converting visitors into paying members while maintaining enterprise engineering quality.

## Requirements

### R1. Premium Page Polish and Realistic Data
Fully implement, refine, and polish all 8 baseline routes (`/`, `/about`, `/services`, `/pricing`, `/schedule`, `/trainers`, `/gallery`, `/contact`) and secondary routes (`/verify`, `/privacy`, `/terms`). Replace any placeholder copy, generic names, or empty blocks with realistic, brand-specific Divinity business data. Maintain clear conversion goals (enquiry booking, memberships, or contacts) on every key page.

### R2. WebGL AuraCanvas Technical Evaluation
Evaluate the archived WebGL particle shader (`AuraCanvas`) located in `Divinity/reference/divinity-website/src/components/marketing/aura-canvas.tsx` against the current 2D canvas/CSS implementation (`BreathHero` & `Ambient`). Compare them across bundle size, Lighthouse performance budget (First Load JS <= 210kB), accessibility (WCAG AA focus rings, `prefers-reduced-motion` compliance), SEO, GPU/CPU usage, and maintenance cost. If superior without performance degradation, integrate as progressive enhancement. Otherwise, retain it as reference and document the decision in the Project Bible (`DECISION_LOG.md`) and create a new ADR (ADR 0013) under `design/adr/`.

### R3. CMS Integration & Graceful Fallback
Ensure the website integrates with Sanity CMS for dynamic fields (disciplines, plans, testimonials). The integration must support a zero-configuration static fallback so that the site compiles and runs successfully even if Sanity API or Brevo environment variables are missing.

### R4. Comprehensive Automated Test Coverage
Add and expand Vitest unit tests in `lib/**/*.test.ts` and Playwright E2E tests in `e2e/` to cover new features, interactions, forms, and pages.

### R5. Project Bible and ADR Updates
Ensure the Project Bible (`PROJECT_BIBLE/04_Public_Website.md`, `DECISION_LOG.md`) and design docs are updated to document all newly implemented features, layout adjustments, and architectural decisions.

### R6. Production Readiness Audit
After implementation, perform a complete production audit covering:
- Accessibility (WCAG 2.2 AA)
- SEO
- Performance
- Security
- Mobile responsiveness
- Browser compatibility
- Progressive enhancement
- Error handling
- Analytics
- Structured data
- PWA readiness

Fix every verified issue before considering the work complete.

### R7. Lighthouse Quality Gates
Verify and document final Lighthouse scores.
Target:
- Performance ≥ 90 (desktop), ≥ 85 (mobile)
- Accessibility = 100
- Best Practices = 100
- SEO = 100

Document any score below target with evidence and explanation.

### R8. Content Quality
Ensure every page contains:
- realistic Divinity business content
- meaningful CTAs
- correct metadata
- Open Graph tags
- Twitter metadata
- structured data
- internal linking
- image alt text
- canonical URLs

No placeholder content may remain unless explicitly marked "Needs Verification."

### R9. Regression Testing
After implementation run:
- `npm run build`
- `npm test`
- `npm run test:e2e`

Verify:
- zero console errors
- zero broken links
- zero hydration errors
- zero accessibility regressions
- zero TypeScript errors

### R10. Documentation
Update:
- `PROJECT_BIBLE`
- `DECISION_LOG`
- `AI_CONTEXT`
- `CHANGELOG`
- `ADRs`

Document every architectural decision and implementation change.

## Acceptance Criteria

### Technical & Quality Verification
- [ ] Production build (`npm run build`) compiles successfully without TypeScript errors, lints, or console warnings.
- [ ] All Vitest unit tests (`npm test`) pass successfully.
- [ ] All Playwright E2E tests (`npm run test:e2e`) pass successfully.
- [ ] The landing page `/` First Load JS bundle size does not exceed the hard budget of 210 kB.
- [ ] Animations are verified to respect the `prefers-reduced-motion` media query and load as progressive enhancements.
- [ ] Certificate verification page (`/verify`) handles valid and invalid certificate formats correctly.
- [ ] Forms (`/contact`, `/newsletter`) validate inputs, prevent double submission, and log graceful fallbacks when Brevo key is absent.

### Content & Visual Design
- [ ] No lorem-ipsum or generic placeholders exist on the public-facing pages.
- [ ] Navigation highlighting, scroll animations (GSAP/Lenis), and theme styling are cohesive, premium, and fully responsive across all viewport sizes.
- [ ] The Project Bible is updated to reflect all changes, including the evaluation outcome of the WebGL AuraCanvas particle shader.

## Final Deliverables

Generate:
1. Production Readiness Report
2. Lighthouse Report
3. Test Report
4. WebGL Evaluation Report
5. Updated Project Bible
6. Updated ADR
7. Remaining Blockers Report

The final report must conclude with one of:
- **GO**
- **CONDITIONAL GO**
- **NO GO**

and provide evidence for the decision. If CONDITIONAL GO or NO GO is returned, list every remaining blocker with severity and recommended resolution.

Do not stop after implementing features. Continue until the website satisfies the production quality gates or every remaining blocker has been documented with evidence.
