# GitHub Copilot UBB/TBB Tooling — Brainstorm

Date: 2026-07-09
Status: brainstorm
Research: `docs/context/research/2026-07-09-github-copilot-ubb-tbb-deep-dive.md`

## Problem

GitHub Copilot shifted from PRUs to Usage-Based Billing (UBB) on June 1, 2026.
Customers and sellers are navigating sticker shock, budget uncertainty, competitive questions,
and complex controls — without great tooling to help them quickly understand impact and take action.

## Goal

Build a portable, high-ROI toolset that makes UBB transparent, manageable, and defensible —
for both customers (admins, engineering leads) and sellers (AEs, SEs, SSPs).

## Audiences

| Audience | Pain | What They Need |
|----------|------|----------------|
| Org/Enterprise admins | "What will I pay?" | Cost estimator, budget setup guide, usage report analysis |
| Engineering leads / dev managers | "How do we optimize?" | Token optimization checklist, model selection guide |
| Sellers (AEs/SSPs) | "Customer is panicking" | Talk track guide, competitive comparison, ROI calculator |
| Cost-conscious CIOs | "How do I control overage?" | Budget hierarchy explainer + configurator |

## Product Ideas (Ranked by ROI vs Build Effort)

### Tier 1 — High ROI, Low Effort (build first)

**1. UBB Cost Estimator (interactive HTML artifact)**
- Inputs: seat count (Business/Enterprise), usage intensity (light/medium/heavy/agent-heavy),
  primary model (auto-select categories: lightweight/versatile/powerful)
- Output: estimated monthly AI credit cost, vs included pool, vs overage threshold
- Include promo vs post-promo (Sep 1) comparison
- Show pooling efficiency gain vs per-user model
- Competitive column: "$0 seat" competitor estimated total spend comparison
- ROI: works for both seller demos and customer self-service

**2. Budget Controls Setup Guide (interactive HTML)**
- Walk through the 4-level budget hierarchy (enterprise → cost center → cost center ULB → individual ULB)
- Interactive: enter your org structure, see recommended budget config
- Output: copy-pasteable budget setup checklist
- Link to docs for each step
- ROI: directly reduces admin confusion and "how do I set this up" support load

**3. Token Optimization Checklist (HTML or Markdown skill)**
- Based on the harness improvements: prompt caching, tool search, Auto routing
- User-facing: what devs can do (model choice, session habits, prompt style)
- Admin-facing: what admins can control (budget levels, usage reports, model policies)
- ROI: helps customers reduce overage before it hits

### Tier 2 — Medium ROI, Medium Effort

**4. Competitive TCO Comparator**
- Side-by-side: GitHub Copilot UBB vs "$0 seat" competitor model
- Inputs: seat count, expected usage, competitor per-token rate, minimum commit
- Output: total expected monthly spend for each
- Highlight: pooling efficiency, included credits, governance layer
- Can use in seller conversations to defuse sticker shock

**5. UBB Conversation Coach (skill or interactive guide)**
- Seller-facing interactive talk track
- Sequence: Empathy → Reframe → Core Truth → Competitive Frame
- Objection cards with "what to say" / "discovery question" pairs
- Built from the field page's exact content — zero hallucination risk
- Can be a standalone HTML artifact OR a Copilot skill for sellers

**6. Usage Report Analyzer (skill prompt)**
- Prompt template: paste usage report CSV → get: top consumers, model distribution,
  cost shape, optimization recommendations
- Works with April/May billing preview exports
- NOT a dashboard (no internal data); just a prompt-based analysis layer

### Tier 3 — Longer Build

**7. P3 Pre-Purchase Calculator**
- Is upfront commit better than PAYG for this customer?
- Inputs: projected monthly usage, discount tier, MACC status
- Output: break-even point, NPV at 5-15% discount
- Tricky: needs accurate usage projection (directional, not precise)

**8. UBB Readiness Assessment (interactive questionnaire)**
- 10-15 questions covering: current seat count, usage patterns, budget governance maturity,
  admin tooling state, agentic adoption level
- Output: readiness score + prioritized action plan
- Could be HTML artifact or Copilot skill

## Recommended Build Order

1. **UBB Cost Estimator** — standalone HTML artifact, self-contained, zero auth required
2. **Budget Controls Setup Guide** — HTML artifact or markdown skill
3. **Token Optimization Checklist** — quick-win, pairs with estimator
4. **Competitive TCO Comparator** — seller-facing, high conversation value
5. **Conversation Coach** — seller/SE upskilling
6. **Usage Report Analyzer** — skill prompt template

## Skill vs HTML Artifact Decision

| Tool | Best Format | Reason |
|------|-------------|--------|
| Cost Estimator | HTML artifact | Interactive, embeddable, shareable |
| Budget Setup Guide | HTML artifact | Visual hierarchy diagram + steps |
| Token Optimization | Markdown / skill | Reference checklist, often inline |
| Competitive TCO | HTML artifact | Side-by-side visual comparison |
| Conversation Coach | HTML artifact | Clickable objection handler cards |
| Report Analyzer | Skill prompt | Runs in Copilot context with pasted data |

## Key Constraints

- All tools must use only PUBLIC data (docs.github.com, github.blog, public pricing tables)
- No internal impact dashboard data in any customer-facing tool
- Pricing tables should link to canonical source and note they can change
- Promo period (Jun-Aug) vs standard (Sep 1+) must be explicit in estimators
- Model pricing is volatile — tools should source from docs or be easily updatable

## Success Criteria

- Seller can use the Cost Estimator in a 5-minute customer call to defuse sticker shock
- Admin can use Budget Setup Guide to configure controls in under 30 minutes
- Each tool links to canonical GitHub docs for verification
- No tool requires login or Microsoft internal access to use
