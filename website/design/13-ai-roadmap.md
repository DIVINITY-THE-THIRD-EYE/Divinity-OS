# 13 — AI Roadmap (Future Product)

Forward-looking modules for Divinity's evolution into a digital wellness platform. **Not part of the
approved website upgrade** — these belong to the future product (with its own backend/auth, per the
README). Listed with a **free/open-weight-first** approach and honest trade-offs.

> Reality check on "free + AI": open-weight models (Llama, Qwen, Whisper, MediaPipe) have **no licence
> fee** but need compute (self-host/GPU) and are lower-quality than frontier APIs. Hosted frontier LLMs
> (Claude/GPT/Gemini) are **metered, not free** at scale. Recommendation: **rules/heuristics first**,
> add a small open model where it clearly helps, reserve paid LLMs for high-value flows behind cost caps.

---

## Phasing
- **AI-0 (cheap, near-term):** deterministic personalization with **no model** (the existing
  `PlanCalculator` is already AI-0). Highest ROI, zero risk.
- **AI-1 (open models, self-host):** breathing/meditation guidance, recommendations, STT/TTS.
- **AI-2 (frontier APIs, metered):** conversational onboarding/coach, nutrition assistant — behind
  budgets, caching, and consent.
- **AI-3 (on-device/edge):** pose analysis, wearable insight — privacy-preserving.

## Modules

| Module | Approach (free/open first) | Trade-off / cost | Privacy | Phase |
|---|---|---|---|---|
| **AI onboarding** | Start as a guided quiz (AI-0, rules) → optionally a chat using a small open LLM (Llama/Qwen) or a metered API for free-text intake. | Rules = free/instant; LLM = compute/£. | Keep intake answers local until account exists. | AI-0→2 |
| **Yoga recommendations** | Heuristic engine over goals/level/history (AI-0); later a lightweight recommender (matrix factorisation / embeddings) once usage data exists. | Heuristics free; ML needs data. | On-device or server with consent. | AI-0→1 |
| **Nutrition assistant** | Curated rule-based plans + food DB (e.g. open USDA data) first; LLM Q&A later (metered) with **medical disclaimers** + guardrails. | LLM hallucination risk → restrict scope, cite sources. | Health data = sensitive; explicit consent, encryption. | AI-1→2 |
| **Breathing coach** | **Deterministic** pacing (the hero already does 4-4-6!) + audio cues; optional adaptive pacing from heart-rate (wearable). No LLM needed. | Essentially free; great UX. | HR data on-device. | AI-1 |
| **Meditation guidance** | Scripted/guided audio library + **open TTS (Piper/Coqui)** for narration; later personalised scripts via LLM. | Open TTS free, robotic-ish; paid TTS (ElevenLabs) better but metered. | Minimal. | AI-1→2 |
| **Posture / pose analysis** | **On-device pose estimation** — MediaPipe Pose / TensorFlow MoveNet / BlazePose (free, browser/mobile). Compare joint angles to target asana; give cues. | Free + private; accuracy varies; **not medical advice**. | **On-device only** — never upload video. | AI-3 |
| **Voice assistant** | **Whisper** (open STT, on-device/transformers.js) + intent routing + open/edge TTS. Frontier LLM only for complex dialog (metered). | Whisper free; latency/size; LLM £. | Process audio locally where possible. | AI-2→3 |
| **Wearable integration** | **Apple HealthKit / Health Connect** (free SDKs) for mindful minutes, HR, workouts → feed breathing/insights. | Free SDKs; native app required. | Health permissions, on-device aggregation. | AI-1→3 |
| **Personalised progress insights** | Stats/streaks + simple anomaly/trend detection (AI-0/1); natural-language summaries via small/metered LLM. | Charts free; NL summary optional. | User-owned data; export/delete. | AI-1→2 |

## Cross-cutting principles
1. **Disclaimers & safety:** wellness/medical guidance must carry disclaimers, avoid diagnosis, and
   route to professionals for red-flags (injury, medical conditions — Divinity already mentions therapeutic intake).
2. **Privacy-by-design:** prefer on-device (pose, HR, audio); explicit consent for any health data;
   encryption at rest; export/delete (GDPR/Indian DPDP-aware).
3. **Cost control:** cache aggressively; cap tokens; degrade to rules when budgets hit; never put an
   unbounded LLM call in a hot path.
4. **Graceful degradation:** every AI feature has a non-AI fallback (mirrors the site's CMS-or-fallback ethos).
5. **No AI on the marketing site now:** the current site stays static/fast; these run in the future app/product.

## Free/open tool shortlist
- **Pose:** MediaPipe, TF MoveNet/BlazePose (browser + mobile, free).
- **STT:** Whisper (open weights), `transformers.js` for in-browser.
- **TTS:** Piper, Coqui TTS (FOSS).
- **LLM (open):** Llama, Qwen, Mistral — self-host (Ollama free locally) for dev; metered hosting for prod.
- **Vector/recsys:** pgvector on Supabase (free tier), or Orama (FOSS) for on-device.
- **Health:** HealthKit, Health Connect (free SDKs).
