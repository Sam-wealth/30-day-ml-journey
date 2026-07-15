# Power BI Dashboard — Build Guide
**HR Analytics | Sam Akande Bolarinwa**

---

## Color Palette (from Requirements sheet)
| Slot | Hex | Use |
|---|---|---|
| 1 | `#1C2D73` | Page backgrounds / dark headers |
| 2 | `#243A94` | Primary KPI cards |
| 3 | `#2C47B5` | Chart fills (primary) |
| 4 | `#3A58CF` | Chart fills (secondary) |
| 5 | `#5B74D7` | Accent / hover |
| 6 | `#8C9DE3` | Light bars / labels |
| White | `#FFFFFF` | Text on dark backgrounds |

---

## DAX Measures (all 5 required)

```dax
Total Employee    = COUNT(Employee[ID_employe])
Headcount         = CALCULATE([Total Employee], Employee[Attrition] = "No")
Termination       = CALCULATE([Total Employee], Employee[Attrition] = "Yes")
Termination Rate  = [Termination] / [Headcount]
Salary            = CALCULATE(SUM(Employee[Salary]), Employee[Attrition] = "No")
```

---

## Page 1 — Executive Summary

**Layout:** 5 KPI cards across top · 2 charts below

| Visual | Field | Notes |
|---|---|---|
| Card | Total Employee | Large font, primary blue |
| Card | Headcount | Green accent |
| Card | Termination | Red accent |
| Card | Termination Rate | % format |
| Card | Salary | Currency format |
| Bar chart | Employees by Department | Horizontal |
| Donut | Employment Type (FT vs Contractor) | 2-color |

---

## Page 2 — Workforce Composition

| Visual | Fields | Notes |
|---|---|---|
| Donut | Gender (current employees only) | Filter: Attrition = No |
| Bar | Education level distribution | Sort descending |
| Bar | Age Group distribution | |
| Bar | Job Role headcount | Horizontal, top 8 |
| Card | Contractor % of workforce | |

---

## Page 3 — Attrition Overview

| Visual | Fields | Notes |
|---|---|---|
| Bar | Attrition rate by Department | % on axis |
| Bar | Attrition rate by Gender | |
| Line | Quarterly New Hires vs Terminations | Dual line, shared axis |
| Line | Monthly Termination Trend | DateDeparture by month |
| Card | Overall Termination Rate | Prominent placement |

---

## Page 4 — Satisfaction Intelligence *(Layer 4)*

| Visual | Fields | Notes |
|---|---|---|
| Clustered Bar | Attrition % by Job Satisfaction | 4 bars |
| Clustered Bar | Attrition % by Work-Life Balance | 4 bars |
| Clustered Bar | Attrition % by Environment Satisfaction | 4 bars |
| Clustered Bar | Attrition % by Job Involvement | 4 bars |
| Matrix / Heatmap | Department × Job Satisfaction → Attrition % | Conditional formatting: red = high |
| Bar | Composite Risk Score distribution | Count by score 0–4 |

**Slicer:** Department · Employment Type · Gender

**Headline callout (text box):**
> "HR employees with Low Job Satisfaction: 45.5% attrition — the company's most vulnerable segment"

---

## Page 5 — Performance & Overtime *(Layer 5)*

| Visual | Fields | Notes |
|---|---|---|
| Clustered Bar | Attrition % by OverTime (Yes/No) | Stark 2-bar comparison |
| Matrix | OT × Performance Rating → Attrition % | Conditional formatting |
| Bar | Avg Salary Hike by Performance Rating | Highlight Outstanding vs rest |
| Bar | OT Rate % by Department | |
| Scatter | YearsWithCurrManager vs Attrition | Bubble size = headcount |
| Bar | Avg Training Sessions: Attrition Yes vs No | |

**Headline callout (text box):**
> "OT employees with Good/Low performance ratings: 60% attrition — the burnout zone"

---

## Page 6 — Compensation

| Visual | Fields | Notes |
|---|---|---|
| Line | Monthly Salary Trend | DateStart by month, avg Salary |
| Scatter | YearsAtCompany vs Salary | Color by EmploymentType |
| Scatter | TotalWorkingYears vs Salary | Color by Gender |
| Bar | Avg Salary by Education | Expected: counterintuitive result |
| Bar | Avg Salary by Employment Type | FT vs Contractor |

---

## Slicers (global, all pages)
- Department
- Gender
- Employment Type (Full-time / Contractor)
- Attrition (Yes / No)
- Year (from DateStart)

---

## Navigation
Use bookmark buttons for page navigation.
Place nav bar on left side or top strip, consistent across all 6 pages.
Label pages clearly: Overview · Workforce · Attrition · Satisfaction · Performance · Compensation

---

## Tips for Polish
- Use a dark background (`#1C2D73`) with white text for KPI cards
- Add a company logo placeholder top-left on every page
- Use conditional formatting on all matrices (white → dark blue scale)
- Disable gridlines on all charts
- Use consistent bar spacing and font size (Segoe UI, 11pt body)
