import type { KeyboardEvent } from "react";

const FOCUSABLE =
  'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

/**
 * Keep keyboard focus inside a modal container. Attach to the container's
 * onKeyDown; on Tab/Shift+Tab at the boundaries it wraps to the other end.
 */
export function trapTab(e: KeyboardEvent<HTMLElement>): void {
  if (e.key !== "Tab") return;
  const focusables = e.currentTarget.querySelectorAll<HTMLElement>(FOCUSABLE);
  if (focusables.length === 0) return;
  const first = focusables[0];
  const last = focusables[focusables.length - 1];
  if (e.shiftKey && document.activeElement === first) {
    e.preventDefault();
    last.focus();
  } else if (!e.shiftKey && document.activeElement === last) {
    e.preventDefault();
    first.focus();
  }
}
