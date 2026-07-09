# GitHub Copilot Usage-Based Billing (UBB/TBB) Deep Dive

Checked: 2026-07-09
Budget mode: deep

## Question

What is GitHub Copilot's Usage-Based Billing (UBB/TBB) model, what are the exact mechanics,
and what tools/skills could we build to help customers and sellers navigate it with high ROI?

## Findings

### The Change: PRUs → AI Credits (effective June 1, 2026)

GitHub Copilot replaced Premium Request Units (PRUs) with **GitHub AI Credits**.

- **1 AI credit = $0.01 USD**
- Credits = tokens consumed × per-model rate
- Token types billed: input, output, cached input (+ cache write for Anthropic)
- **Code completions and Next Edit Suggestions remain unlimited / not billed**
- Copilot code review also consumes GitHub Actions minutes

### Plan Pricing (unchanged)

| Plan | Price | Included AI Credits/user/mo | Promo (Jun–Aug 2026) |
|------|-------|-----------------------------|----------------------|
| Copilot Business | $19/user/mo | 1,900 credits ($19) | 3,000 credits ($30) |
| Copilot Enterprise | $39/user/mo | 3,900 credits ($39) | 7,000 credits ($70) |
| Copilot Pro | $10/mo | $10 in credits | — |
| Copilot Pro+ | $39/mo | $39 in credits | — |

### Pooling Model (key differentiator)

Credits are pooled at the **billing entity level** (enterprise or org), not per-user buckets.
100 Business users = 190,000 shared credits. Heavy users draw more; light users offset.
- Credits reset 00:00 UTC on 1st of each month. No rollover.
- Adding seats mid-cycle: pool grows immediately.
- Removing seats mid-cycle: pool shrinks at start of next cycle only.

### Token Pricing by Model (per 1M tokens)

**Lightweight:**
- GPT-5 mini: $0.25 in / $0.025 cached / $2.00 out
- GPT-5.4 nano: $0.20 in / $0.02 cached / $1.25 out
- GPT-5.4 mini: $0.75 in / $0.075 cached / $4.50 out

**Versatile:**
- Claude Sonnet 4.x: $3.00 in / $0.30 cached / $3.75 cache write / $15.00 out
- GPT-5.4: $2.50 in / $0.25 cached / $15.00 out (≤272K); $5.00/$22.50 (>272K)
- Claude Haiku 4.5: $1.00 in / $0.10 cached / $5.00 out

**Powerful:**
- GPT-5.5: $5.00 in / $0.50 cached / $30.00 out (≤272K)
- Claude Opus 4.x: $5.00 in / $0.50 cached / $6.25 write / $25.00 out
- Claude Fable 5 / Opus 4.8 fast: $10.00 in / $1.00 cached / $12.50 write / $50.00 out
- Gemini 2.5 Pro: $1.25 in / $0.125 cached / $10.00 out

### Budget Control Hierarchy

Four levels, applied in most-specific-wins order:

1. **Individual user-level budget (ULB)** — caps user's total draw from pool + overage.
   A $0 budget blocks immediately. Overrides all others for that user.
2. **Cost center ULB** — per-user default for a cost center (e.g., $20 eng / $5 marketing).
   Overrides universal ULB for cost center members.
3. **Universal ULB** — enterprise-wide per-user default. Applied at first credit consumption.
4. **Cost center budget** — caps total metered charges for a team *after pool exhausted*.
5. **Enterprise spending limit** — caps total metered charges across entire enterprise after pool.
6. **Org-level budget** — caps org users' metered charges after pool exhausted.

Key behaviors:
- ULB is active during *both* pool phase and metered phase. Others are metered-phase only.
- No fallback to cheaper model when budget exhausted. Hard stop.
- Notification at various consumption levels sent to admins.

### Token Efficiency Mechanics (GitHub-side improvements)

GitHub has been aggressively reducing token waste at the harness level:

**Prompt caching:**
- Reuses model state (KV tensors) for repeated prompt prefixes.
- Cached tokens are up to 10× cheaper than uncached.
- Extended 24h cache retention for OpenAI models in VS Code: cache hit rates
  increased 300-900% for gaps of 30-60 minutes vs defaults.

**Tool search (deferred tool definitions):**
- Instead of loading all tool schemas every turn, loads lightweight metadata first,
  full schema on demand. Reduces context overhead significantly for agent sessions.

**Auto model routing (HyDRA):**
- Routes tasks to the model that fits based on: reasoning depth, code complexity,
  debugging difficulty, tool orchestration needs.
- Real-time health signals: availability, utilization, speed, error rates, cost.
- HyDRA (Conservative): ties OpenRouter Auto on SWEBench at 3.3× the savings.
- HyDRA (Aggressive): 72.5% cost savings vs always-Sonnet while maintaining quality.
- Cache-aware routing: holds model steady at cache boundaries, switches only on
  first turn or after compaction.

**GitHub Copilot CLI harness vs model-vendor harnesses:**
- On-par resolution rates vs Claude Code and Codex CLI.
- Lower token consumption on most benchmarks (SWE-bench, SkillsBench, TerminalBench, Win-Hill).
- One shared harness powers CLI, VS Code, GitHub Copilot App, code review, and SDK.

### Billing Preview & Reports

- Usage billing report available since May 12 (April data). Shows AI credits by user,
  model, surface.
- Report is directional; not a recalculated bill. Useful for pattern analysis.
- Preview bill visible on github.com Billing Overview before charges hit.

### Competitive Positioning

Competitor "$0 seat" claims are misleading. The real comparison is:
**Total expected spend = seat access + included usage + pooling efficiency + governance value**

Discovery questions:
- Is included usage bundled or is every token billed separately?
- Is there a minimum annual spend commitment?
- Are credits pooled across heavy/light users?
- What controls exist at enterprise/org/cost center/user level?
- What happens as agentic usage grows?

### Discount Programs (Azure subscription customers)

| # | Program | Discount | Notes |
|---|---------|----------|-------|
| 1 | ADO/Competitor → GH Enterprise Transition Empowerment | 30% | Not stackable |
| 2 | GitHub Pre-Purchase Plan (P3) | 5-15% | Covers full portfolio |
| 3 | GitHub AI Credit P3 | 5-15% | Compete scenarios only |
| 4 | Microsoft Agent P3 | 5-15% | ~30 workloads incl. GH Copilot |
| 5 | UBB Promo (Jun-Aug 2026) | N/A | Auto-applied |
| 6 | Azure Commitment Discounts (ACD/MACC) | Varies | All metered GH products |
| 7 | GitHub Deals Desk | Varies | Highly selective |

All P3s decrement MACC. SKU-level discounts override P3 at list price disadvantage — check carefully.

### UBB Transition 3-Step Field Framework

1. **Get Ready** — bookmark aka.ms/GHCPUBB, study Job Aid, join Office Hours
2. **Assess Customer Impact** — review impact dashboard (do not share with customer)
3. **Engage Customer** — coordinate v-team, 1:1 conversation, share preview report

Customer conversation sequence: Empathy → Reframe Cost as Value → Core Truth (AI usage is inherently variable)

### Upcoming Controls (July 2, 2026 update)

Cost Center and Team Level Controls now available. Customers interested in these should be
proactively contacted with the ACT NOW materials.

## Sources

- https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/
- https://docs.github.com/en/copilot/how-tos/manage-and-track-spending/prepare-for-usage-based-billing
- https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing
- https://docs.github.com/en/copilot/concepts/billing/budgets-for-usage-based-billing
- https://github.blog/ai-and-ml/github-copilot/getting-more-from-each-token-how-copilot-improves-context-handling-and-model-routing/
- https://code.visualstudio.com/blogs/2026/06/17/improving-token-efficiency-in-github-copilot
- https://github.blog/ai-and-ml/github-copilot/evaluating-performance-and-efficiency-of-the-github-copilot-agentic-harness-across-models-and-tasks/
- https://github.com/orgs/community/discussions/192948
- https://github.blog/changelog/2026-05-12-april-reports-are-now-available-to-prepare-for-usage-based-billing/
- Internal: SharePoint GitHub Sales TBB page (aka.ms/GHCPUBB) — traversed 2026-07-09

## Applies When

- Building tools to help customers understand/manage UBB costs
- Helping sellers have UBB conversations with customers
- Building cost estimators, budget configurators, or optimization advisors
- Competitive scenarios where "$0 seat" pricing comes up
- Token optimization guidance for engineering teams

## Stale When

- Model pricing table changes (check docs.github.com/copilot/reference/copilot-billing/models-and-pricing)
- Promotional pricing period ends (Aug 31, 2026 — standard credits resume Sep 1)
- New budget control levels added
- HyDRA routing model is updated or renamed

## Rejected Approaches

- Do NOT build tools that read from the internal impact dashboard (aka.ms/ubb_msft_report) —
  data is directional and must not be shared with customers.
- Do NOT promise exact cost forecasts — usage is variable by nature (acknowledged even in field guidance).
- Do NOT suggest $0-seat competitive pricing is equivalent — total spend framing is the right lens.

## Impact On Current Project

This is a new domain, not an existing skill area. A new skill or tool bundle is warranted.
Recommended next step: create a brainstorm + plan for a UBB/TBB tooling skill.
See: `docs/brainstorms/2026-07-09-github-copilot-ubb-tbb-tooling.md`
