import { createClient, type SanityClient } from "@sanity/client";

const projectId = process.env.NEXT_PUBLIC_SANITY_PROJECT_ID;
const dataset = process.env.NEXT_PUBLIC_SANITY_DATASET || "production";
const apiVersion = process.env.NEXT_PUBLIC_SANITY_API_VERSION || "2024-01-01";

/**
 * The site is designed to run with zero configuration.
 * If a Sanity project id is present, we create a client and content can be
 * fetched from the CMS. If not, callers fall back to lib/content.ts.
 */
export const sanityEnabled = Boolean(projectId);

export const sanity: SanityClient | null = sanityEnabled
  ? createClient({ projectId, dataset, apiVersion, useCdn: true })
  : null;

/**
 * Fetch from Sanity, but never let a CMS hiccup break the page —
 * fall back to the provided local value on any error or when disabled.
 */
export async function fetchOrFallback<T>(
  query: string,
  fallback: T,
  params: Record<string, unknown> = {}
): Promise<T> {
  if (!sanity) return fallback;
  try {
    const data = await sanity.fetch<T>(query, params);
    return data && (!Array.isArray(data) || data.length) ? data : fallback;
  } catch {
    return fallback;
  }
}
