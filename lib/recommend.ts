// Pure plan-recommendation logic, extracted from PlanCalculator so it can be
// unit-tested independently of React.

export type Commit = "Try it" | "Monthly" | "Quarterly" | "Yearly";
export type Focus = "One discipline" | "Everything";

export type PlanName = "The Yogi" | "Drop-in" | "The Seeker" | "The Devotee";

export function recommend(commit: Commit, focus: Focus, oneToOne: boolean): PlanName {
  if (oneToOne || commit === "Yearly") return "The Yogi";
  if (commit === "Try it") return "Drop-in";
  if (focus === "One discipline" && commit === "Monthly") return "The Seeker";
  return "The Devotee";
}
