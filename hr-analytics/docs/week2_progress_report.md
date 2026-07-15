# HR Analytics — Week 2 Progress Report
**Author:** Sam Akande Bolarinwa  
**Phase:** 1 — People & HR Analytics  
**Tools:** SQL Server (SSMS) · Power BI  
**Dataset:** 1,470 employees · 38 columns

---

## Layer 4 — Satisfaction vs Attrition

### What We Measured
Four dimensions of employee satisfaction cross-referenced against attrition:
Job Satisfaction, Work-Life Balance, Environment Satisfaction, Job Involvement.

### Key Findings

**Job Involvement is the strongest satisfaction-side predictor of attrition.**
Employees with Low involvement leave at 33.7% — nearly 4x the rate of Very High involvement (9.0%).
This is more predictive than Job Satisfaction alone.

**Work-Life Balance "Bad" is a critical flag.**
Employees rating their WLB as Bad leave at 31.2%, more than double the "Better" cohort at 14.2%.
The jump from Bad to Good is the most impactful improvement the business could make.

**HR Department is the most vulnerable segment in the company.**
HR employees with Low Job Satisfaction have a 45.5% attrition rate — nearly 1 in 2 leaves.
This is the highest attrition rate of any department-satisfaction combination in the dataset.

**Environment Satisfaction follows a sharp cliff, not a gradient.**
Low environment satisfaction (25.4%) is nearly double High (13.7%), but moving from High to Very High
(13.5%) produces almost no additional retention benefit. The priority is pulling employees out of "Low."

### Satisfaction Risk Score Framework
A composite score was built across all four dimensions (0–4 scale).
Employees scoring 3–4 are classified as maximum flight risk and should be prioritised
for retention intervention before other signals surface.

---

## Layer 5 — Performance & Overtime

### What We Measured
Overtime status, performance ratings, salary hikes, training frequency,
promotion lag, and manager tenure — all cross-referenced against attrition.

### Key Findings

**Overtime is the single most powerful attrition driver in the dataset.**
Employees doing overtime leave at 30.5% vs 10.4% for non-OT employees — a 3x multiplier.
No satisfaction score, demographic, or compensation variable produces a stronger signal.

**OT + Good/Low Performance = 60% attrition rate.**
The burnout matrix (Query 5.3) reveals the most dangerous cohort:
employees doing overtime who are rated Good or Low leave at a 60% clip.
These employees are being overworked without performance recognition — a compounding failure.

**The reward structure is flat, and it is costing the company talent.**
Good, Low, and Excellent performers all receive approximately 14% salary hikes.
Only Outstanding performers are differentiated at 21.8%.
A "Good" performer doing overtime with a 14% hike and a 60% exit rate is the company's
most expensive retention problem.

**Short manager tenure is a leading indicator of departure.**
Employees who left averaged 2.85 years with their current manager vs 4.37 for stayers.
Manager relationship quality appears more predictive of departure than promotion timing (2.73 vs 4.25 years).

**Counter-intuitive: employees who left were promoted more recently (1.82 vs 2.19 years).**
This rules out stagnation as the primary cause. The pattern points to early disengagement —
employees who arrive, get a quick promotion bump, then leave because the environment
or workload doesn't match expectations.

**Training gap is directional but not decisive.**
Employees who left averaged 2.62 training sessions vs 2.83 for those who stayed.
Training investment is a weak retention signal alone, but likely amplifies engagement
when combined with better WLB and involvement scores.

---

## Cross-Layer Synthesis — The Retention Equation

Three compounding risk factors emerge from combining Layer 4 and Layer 5:

| Risk Factor | Attrition Rate |
|---|---|
| Baseline (no risk flags) | ~7–10% |
| OT alone | 30.5% |
| OT + Low Job Satisfaction | 35.7% |
| OT + Low Job Involvement | ~38%+ |
| OT + Good/Low Performance Rating | 60.0–60.5% |

**Strategic recommendation for the business:**
The fastest path to reducing attrition is not a pay raise — it is overtime policy reform
combined with differentiated performance recognition for the mid-tier (Good/Excellent rated)
employee pool. These two levers, combined, address the 60% burnout cohort directly.

---

## Dashboard Plan (Week 2 Delivery)

### Page 1 — Executive Summary
KPI cards: Total Employees · Headcount · Terminated · Termination Rate · Total Salary

### Page 2 — Workforce Composition
Gender split · Department breakdown · Employment type (FT vs Contractor) · Education levels · Age groups

### Page 3 — Attrition Deep Dive
Attrition by department · By gender · Quarterly hire vs termination trends · Monthly termination trend

### Page 4 — Satisfaction Intelligence *(Layer 4)*
4-quadrant view: Job Satisfaction / WLB / Environment / Involvement vs attrition rate  
Department × Satisfaction heatmap  
Composite Risk Score distribution

### Page 5 — Performance & Overtime *(Layer 5)*
OT vs Non-OT attrition bar  
Burnout matrix: OT × Performance Rating  
Salary hike distribution by performance  
Manager tenure vs attrition scatter

### Page 6 — Compensation
Salary trends · Salary spread by tenure · Salary by employment type · Education vs pay paradox

---

## Week 1 Recap

| Finding | Metric |
|---|---|
| R&D dominates headcount | 67% of workforce |
| Contractor share | 16.6% of total employees |
| Contractor pay premium | Contractors earn 64% more in comparable roles |
| Education vs pay paradox | Masters degree holders earn less than Bachelors |

---

## Status

| Layer | Topic | Status |
|---|---|---|
| Cleaning | Data prep & validation | ✅ Done |
| Layer 1 | Workforce Composition | ✅ Done |
| Layer 2 | Attrition & Retention | ✅ Done |
| Layer 3 | Compensation Analysis | ✅ Done |
| Layer 4 | Satisfaction vs Attrition | ✅ Done |
| Layer 5 | Performance & Overtime | ✅ Done |
| Dashboard | Power BI (6 pages) | 🔄 In Build |

---

*Part of a 30-day industry rotation portfolio. Next: E-commerce & Sales Analytics.*
