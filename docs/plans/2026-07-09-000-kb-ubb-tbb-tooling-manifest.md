# KB Plan: GitHub Copilot UBB/TBB Tooling

Date: 2026-07-09
Brainstorm: `docs/brainstorms/2026-07-09-github-copilot-ubb-tbb-tooling.md`
Research: `docs/context/research/2026-07-09-github-copilot-ubb-tbb-deep-dive.md`
Status: plan-to-work gate OPEN (human approval required before execution)

## Objective

Build a 6-tool suite that gives customers and sellers a clear, fast, zero-login path to
understand and act on GitHub Copilot Usage-Based Billing — reducing sticker shock, overage
surprises, and lost deals.

## Dependency DAG

```
[S1] UBB Cost Estimator (HTML)          ← independent, start here
[S2] Budget Controls Setup Guide (HTML) ← independent
[S3] Token Optimization Checklist (MD)  ← independent
[S4] Competitive TCO Comparator (HTML)  ← depends on S1 (shares pricing model)
[S5] Conversation Coach (HTML)          ← depends on S3 (shares optimization content)
[S6] Usage Report Analyzer (skill)      ← independent
```

S1, S2, S3, S6 are parallel-safe. S4 after S1. S5 after S3.

## Slices

### Slice S1 — UBB Cost Estimator

**Goal:** Interactive HTML tool for estimating monthly AI credit spend.

**Inputs:**
- Plan: Business ($19) or Enterprise ($39)
- Seat count (number input)
- Usage profile: Light / Medium / Heavy / Agentic-Heavy
  (maps to estimated tokens/user/month for each model tier)
- Primary model category: Lightweight / Versatile / Powerful / Auto
- Time period: During promo (Jun-Aug 2026) or Post-promo (Sep 1+)

**Outputs:**
- Included pool (credits + $)
- Estimated usage (credits + $)
- Net: surplus or overage
- Pooling efficiency note (vs per-user model)
- Optional: competitor "$0 seat" TCO side panel

**Token assumptions (baked in, linkable to docs):**
- Light: ~500K tokens/user/month (quick chat, short sessions)
- Medium: ~2M tokens/user/month (regular coding + chat)
- Heavy: ~8M tokens/user/month (long sessions, multi-file)
- Agentic-Heavy: ~30M tokens/user/month (autonomous multi-hour agent runs)

**Model rate defaults (per 1M tokens, input/output weighted):**
- Lightweight: ~$0.50 blended
- Versatile: ~$3.50 blended (Claude Sonnet / GPT-5.4)
- Powerful: ~$8.00 blended (Claude Opus / GPT-5.5)
- Auto: ~$2.00 blended (HyDRA routing average)

**Verification:** Render in browser, check all input combinations produce valid output.
No negative numbers, no NaN, overage clearly distinguished from pool consumption.

**Files:** `docs/reports/ubb-cost-estimator.html` (self-contained)

---

### Slice S2 — Budget Controls Setup Guide

**Goal:** Interactive HTML walkthrough of the 4-level budget hierarchy.

**Content:**
- Visual hierarchy diagram: Enterprise → Cost Center → Cost Center ULB → Individual ULB
- For each level: what it controls, when to use it, how to set it
- "When a user hits a limit, here's what happens" flow (no fallback to cheaper model)
- Recommended configs for common org shapes:
  - Small org (<100 seats): just enterprise spending limit + universal ULB
  - Mid-size (100-1000): add cost center budgets by department
  - Large enterprise: full stack with cost center ULBs per team
- Links to canonical docs for each step

**Verification:** All three org patterns render correctly, hierarchy diagram is readable.

**Files:** `docs/reports/ubb-budget-setup-guide.html`

---

### Slice S3 — Token Optimization Checklist

**Goal:** Practical checklist for reducing token spend without reducing output quality.

**Sections:**
1. **Admins** — model policy configuration, budget alerts, usage report review cadence
2. **Developers** — prompt habits, session management, model selection, cache awareness
3. **Team leads** — agentic workflow governance, review cadence for high-consumption users
4. **What GitHub Does For You** — Auto routing, prompt caching, tool search (not user-actionable but builds confidence)

**Format:** Markdown file + HTML companion with collapsible sections.

**Verification:** All items are actionable, all GitHub-side claims sourced to docs/blogs.

**Files:** `docs/reports/ubb-token-optimization-checklist.md` + `.html`

---

### Slice S4 — Competitive TCO Comparator (after S1)

**Goal:** Side-by-side monthly spend comparison: GitHub Copilot UBB vs usage-only competitor.

**Inputs:**
- Seat count
- Expected monthly token volume per user
- Competitor: per-token price (input/output), minimum annual commit
- GitHub plan: Business or Enterprise

**Outputs:**
- GitHub: seat cost + included credits value + pooling efficiency + overage (if any)
- Competitor: seat/access cost + token cost + commit floor
- Total expected monthly spend: GitHub vs Competitor
- Highlight: governance gap (controls, pooling, platform breadth)

**Key message baked in:** Total spend = access + usage + commitments + governance

**Verification:** Outputs match manual calculation for at least 5 representative scenarios.

**Files:** `docs/reports/ubb-competitive-tco.html`

---

### Slice S5 — Conversation Coach (after S3)

**Goal:** Interactive seller/SE talk track for UBB customer conversations.

**Structure:**
- Phase 1: Start with Empathy (what to say, what NOT to say)
- Phase 2: Reframe Cost → Value (3 talking points with data)
- Phase 3: Align on Core Truth (AI usage is variable — industry-wide)
- Phase 4: Competitive Frame (total spend, pooling, governance)
- Objection card deck: clickable, each shows "Customer says" → "You say" → "Discovery question"

**Objection cards from research:**
- "This is a price increase" → "Seat price unchanged, agentic usage = more value"
- "We'll just go with $0 seats" → "Total spend comparison" (link to S4)
- "We can't forecast AI costs" → "Billing preview + budget controls + optimization"
- "What controls do we have?" → Walk through S2 budget hierarchy
- "Competitors don't charge for seats" → pooling + governance value frame

**Verification:** All phases render, objection cards expand/collapse, no broken links.

**Files:** `docs/reports/ubb-conversation-coach.html`

---

### Slice S6 — Usage Report Analyzer (skill prompt)

**Goal:** Skill prompt that helps analyze pasted billing preview CSV/data.

**Prompt template covers:**
- Identify top 10 consumers by AI credit spend
- Break down by model category (lightweight/versatile/powerful)
- Break down by Copilot surface (chat, agent, code review, CLI)
- Flag users whose usage suggests they'd benefit from individual ULB controls
- Estimate post-promo cost delta (3,000→1,900 credits for Business)
- Suggest top 3 optimization actions

**Format:** Skill SKILL.md in `.github/skills/ubb-report-analyzer/`

**Verification:** Run against synthetic usage CSV, confirm output categories are correct.

**Files:** `.github/skills/ubb-report-analyzer/SKILL.md`

---

## Non-Goals (this plan)

- No integration with aka.ms/ubb_msft_report (internal only)
- No authentication layer (all tools are zero-login)
- No real-time pricing API calls (hardcoded with note to check docs for updates)
- No mobile optimization (desktop-first)

## Pricing Update Strategy

All pricing is sourced from `docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing`.
Each tool has a visible "Prices last checked: 2026-07-09" footer with a direct link to the canonical table.
When the table changes, update the baked-in rates and the date.

## Success Metrics

- Estimator: any input combination → valid output in < 1 second
- Budget Guide: a non-technical admin can follow it without external help
- Optimization: each checklist item is independently actionable
- Competitive: manual calc matches tool output within 1% for all test scenarios
- Coach: covers all 5 common objections from field guidance
- Report Analyzer: correctly identifies top consumers and model split from synthetic data

## Human Approval Gate

Before executing any slice, confirm:
1. Tool output may be shared with customers? (all tools use public data only — yes)
2. Pricing assumptions acceptable for June-Aug 2026 promo period? (yes — documented)
3. Build order: S1 → S2 → S3 → (S4 and S5 after dependencies) → S6?
