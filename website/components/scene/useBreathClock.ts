"use client";

import { useSyncExternalStore } from "react";

// Pranayama cadence (seconds): sama-style with a longer exhale. Extracted
// verbatim from the old BreathHero.tsx so every consumer (SilhouetteTier,
// Scene, the hero readout) shares the exact same timing.
const INHALE = 4;
const HOLD = 4;
const EXHALE = 6;
const CYCLE = INHALE + HOLD + EXHALE;

export type BreathPhase = {
  label: "Inhale" | "Hold" | "Exhale" | "Breathe";
  remaining: number;
  breath: number; // 0..1 fullness
};

const easeInOut = (x: number) => 0.5 - 0.5 * Math.cos(Math.PI * x);

/** Pure function — unit-tested directly against known t values. */
export function breathAt(tSec: number): BreathPhase {
  const t = tSec % CYCLE;
  if (t < INHALE) {
    return { label: "Inhale", remaining: INHALE - t, breath: easeInOut(t / INHALE) };
  }
  if (t < INHALE + HOLD) {
    return { label: "Hold", remaining: INHALE + HOLD - t, breath: 1 };
  }
  const e = (t - INHALE - HOLD) / EXHALE;
  return { label: "Exhale", remaining: CYCLE - t, breath: 1 - easeInOut(e) };
}

// ONE shared clock instance (module-level), not one per consumer. `latest`
// updates every frame for imperative canvas/shader reads (getBreath());
// `display` only updates ~4x/sec (matching the original BreathHero's own
// throttle) and is what the reactive hook exposes, so the text readout
// doesn't re-render 60x/sec for no visual benefit.
let latest: BreathPhase = { label: "Inhale", remaining: INHALE, breath: 0 };
let display: BreathPhase = latest;
let lastBucket = -1;
let started = false;
let reduceMotion = false;
const listeners = new Set<() => void>();

function notify() {
  listeners.forEach((l) => l());
}

function tick(startTime: number, now: number) {
  const tSec = (now - startTime) / 1000;
  latest = breathAt(tSec);
  const bucket = Math.floor(tSec * 4);
  if (bucket !== lastBucket) {
    lastBucket = bucket;
    display = latest;
    notify();
  }
  requestAnimationFrame((n) => tick(startTime, n));
}

function ensureStarted() {
  if (started || typeof window === "undefined") return;
  started = true;
  reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (reduceMotion) {
    latest = { label: "Breathe", remaining: 0, breath: 0.6 };
    display = latest;
    notify();
    return;
  }
  requestAnimationFrame((now) => tick(now, now));
}

function subscribe(listener: () => void) {
  ensureStarted();
  listeners.add(listener);
  return () => listeners.delete(listener);
}
function getSnapshot() {
  return display;
}
function getServerSnapshot(): BreathPhase {
  return { label: "Inhale", remaining: INHALE, breath: 0 };
}

/** Reactive — for the text readout. Updates ~4x/sec, never per animation frame. */
export function useBreathPhase() {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}

/** Imperative — for canvas/shader draw loops that already run their own rAF. */
export function getBreath(): BreathPhase {
  ensureStarted();
  return latest;
}
