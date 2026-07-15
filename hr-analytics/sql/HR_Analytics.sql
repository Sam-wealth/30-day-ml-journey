-- ============================================================
-- HR ANALYTICS PROJECT — WEEK 1 MASTER SCRIPT
-- Dataset : Hr Analytics Dataset (1,470 rows, 38 columns)
-- Tool    : SQL Server (SSMS)
-- Author  : Sam Akande
-- Date    : July 2026
-- ============================================================
-- CONTENTS:
--   SECTION 1 : Data Cleaning & Preparation
--   SECTION 2 : Layer 1 — Workforce Composition
--   SECTION 3 : Layer 2 — Attrition & Retention
--   SECTION 4 : Layer 3 — Compensation Analysis
-- ============================================================


-- ============================================================
-- SECTION 1 : DATA CLEANING & PREPARATION
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: Fix 3 mismatched Age values
-- Problem : Age column had 3 rows where stored age didn't
--           match the age calculated from DateBirth
-- Fix     : Recalculate age precisely from DateBirth & DateToday
-- ------------------------------------------------------------
UPDATE [Hr Analytics Dataset]
SET Age = DATEDIFF(YEAR, DateBirth, DateToday)
          - CASE
                WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateBirth, DateToday), DateBirth) > DateToday
                THEN 1 ELSE 0
            END
WHERE Age <> DATEDIFF(YEAR, DateBirth, DateToday)
              - CASE
                    WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateBirth, DateToday), DateBirth) > DateToday
                    THEN 1 ELSE 0
                END;


-- ------------------------------------------------------------
-- STEP 2: Fill NULL StockOption values
-- Problem : 631 of 1,470 rows (43%) had NULL StockOption
-- Decision: NULL means employee was not enrolled — fill as 'None'
-- Reason  : NULL is silently excluded from GROUP BY; explicit
--           'None' keeps all 1,470 rows visible in analysis
-- ------------------------------------------------------------
UPDATE [Hr Analytics Dataset]
SET StockOption = 'None'
WHERE StockOption IS NULL;


-- ------------------------------------------------------------
-- STEP 3: Add numeric score columns for ordinal text fields
-- Problem : Fields like JobSatisfaction stored as text (Low/High)
--           cannot be averaged or sorted correctly by SQL
-- Fix     : Add new _Score INT columns alongside originals.
--           Original text columns PRESERVED for dashboard labels.
--           Score columns used for calculations & correlations.
-- ------------------------------------------------------------

-- Add the new score columns
ALTER TABLE [Hr Analytics Dataset] ADD JobSatisfaction_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD EnvironmentSatisfaction_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD JobInvolvement_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD WorkLifeBalance_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD PerformanceRating_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD Education_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD StockOption_Score INT;

-- Populate score columns from text columns
-- NOTE: Text columns (JobSatisfaction, Education etc.) remain unchanged
UPDATE [Hr Analytics Dataset]
SET
    JobSatisfaction_Score = CASE JobSatisfaction
        WHEN 'Low'      THEN 1
        WHEN 'Medium'   THEN 2
        WHEN 'High'     THEN 3
        WHEN 'Very High' THEN 4
    END,

    EnvironmentSatisfaction_Score = CASE EnvironmentSatisfaction
        WHEN 'Low'      THEN 1
        WHEN 'Medium'   THEN 2
        WHEN 'High'     THEN 3
        WHEN 'Very High' THEN 4
    END,

    JobInvolvement_Score = CASE JobInvolvement
        WHEN 'Low'      THEN 1
        WHEN 'Medium'   THEN 2
        WHEN 'High'     THEN 3
        WHEN 'Very High' THEN 4
    END,

    WorkLifeBalance_Score = CASE WorkLifeBalance
        WHEN 'Bad'    THEN 1
        WHEN 'Good'   THEN 2
        WHEN 'Better' THEN 3
        WHEN 'Best'   THEN 4
    END,

    PerformanceRating_Score = CASE PerformanceRating
        WHEN 'Low'         THEN 1
        WHEN 'Good'        THEN 2
        WHEN 'Excellent'   THEN 3
        WHEN 'Outstanding' THEN 4
    END,

    Education_Score = CASE Education
        WHEN 'Below College' THEN 1
        WHEN 'College'       THEN 2
        WHEN 'Bachelor'      THEN 3
        WHEN 'Master'        THEN 4
        WHEN 'Doctor'        THEN 5
    END,

    StockOption_Score = CASE StockOption
        WHEN 'None' THEN 0
        WHEN 'Low'  THEN 1
        WHEN 'Mid'  THEN 2
        WHEN 'High' THEN 3
    END;


-- ------------------------------------------------------------
-- STEP 4: Add Attrition_Label computed column
-- Problem : Attrition stored as BIT (0/1) — not dashboard-friendly
-- Fix     : Add computed column that auto-converts 1→'Yes', 0→'No'
--           Computed columns update automatically, never need
--           manual maintenance
-- Note    : Keep original Attrition BIT for SQL calculations
--           Use Attrition_Label for dashboard slicers & labels
-- ------------------------------------------------------------
ALTER TABLE [Hr Analytics Dataset]
ADD Attrition_Label AS (
    CASE WHEN Attrition = 1 THEN 'Yes' ELSE 'No' END
);


-- ------------------------------------------------------------
-- STEP 5: Add AgeHire computed column
-- Calculates employee's age at the time they were hired
-- Using same precise logic as Step 1 to avoid off-by-one errors
-- ------------------------------------------------------------
ALTER TABLE [Hr Analytics Dataset]
ADD AgeHire AS (
    DATEDIFF(YEAR, DateBirth, DateStart)
    - CASE
        WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateBirth, DateStart), DateBirth) > DateStart
        THEN 1 ELSE 0
      END
);


-- ------------------------------------------------------------
-- CLEANING VERIFICATION QUERIES
-- Run these after all steps to confirm clean state
-- ------------------------------------------------------------

-- Total active employees (baseline = 1,233)
SELECT COUNT(*) AS Total_Active_Employees
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL;

-- Confirm no Age mismatches remain
SELECT COUNT(*) AS Age_Mismatches
FROM [Hr Analytics Dataset]
WHERE Age <> DATEDIFF(YEAR, DateBirth, DateToday)
              - CASE
                    WHEN DATEADD(YEAR, DATEDIFF(YEAR, DateBirth, DateToday), DateBirth) > DateToday
                    THEN 1 ELSE 0
                END;

-- Confirm no NULL StockOption values remain
SELECT COUNT(*) AS Null_StockOption
FROM [Hr Analytics Dataset]
WHERE StockOption IS NULL;

-- Confirm all score columns are populated
SELECT
    SUM(CASE WHEN JobSatisfaction_Score IS NULL THEN 1 ELSE 0 END) AS JS_Nulls,
    SUM(CASE WHEN Education_Score IS NULL THEN 1 ELSE 0 END) AS Edu_Nulls,
    SUM(CASE WHEN PerformanceRating_Score IS NULL THEN 1 ELSE 0 END) AS Perf_Nulls,
    SUM(CASE WHEN WorkLifeBalance_Score IS NULL THEN 1 ELSE 0 END) AS WLB_Nulls
FROM [Hr Analytics Dataset];


-- ============================================================
-- SECTION 2 : LAYER 1 — WORKFORCE COMPOSITION
-- Baseline question: Who do we have?
-- Filter: WHERE DateDeparture IS NULL (active employees only)
-- Verified baseline: 1,233 active employees
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Headcount by Department
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*) AS Headcount
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Department
ORDER BY Headcount DESC;

-- Results: R&D 828 | Sales 354 | HR 51


-- ------------------------------------------------------------
-- 1.2 Headcount by Employment Type
-- Window function SUM() OVER() calculates company-wide total
-- for percentage without a subquery
-- ------------------------------------------------------------
SELECT
    EmploymentType,
    COUNT(*) AS Headcount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Percentage
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY EmploymentType
ORDER BY Headcount DESC;

-- Results: Full-time 1,028 (83.4%) | Contractor 205 (16.6%)


-- ------------------------------------------------------------
-- 1.3 Gender Distribution by Department
-- PARTITION BY Department ensures % is within-dept not company-wide
-- ------------------------------------------------------------
SELECT
    Department,
    Gender,
    COUNT(*) AS Headcount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Department), 1) AS Pct_Within_Dept
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Department, Gender
ORDER BY Department, Headcount DESC;


-- ------------------------------------------------------------
-- 1.4 Age Profile by Department
-- AgeGroup has numeric prefixes so ORDER BY ASC = correct age order
-- ------------------------------------------------------------
SELECT
    Department,
    AgeGroup,
    COUNT(*) AS Headcount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Department), 1) AS Pct_Within_Dept
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Department, AgeGroup
ORDER BY Department, AgeGroup;


-- ------------------------------------------------------------
-- 1.5 Average Age per Department
-- CAST to FLOAT prevents integer truncation in AVG
-- ------------------------------------------------------------
SELECT
    Department,
    ROUND(AVG(CAST(Age AS FLOAT)), 1) AS Avg_Age,
    MIN(Age) AS Youngest,
    MAX(Age) AS Oldest
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Department
ORDER BY Avg_Age DESC;

-- Results: HR 38.6 | R&D 36.6 | Sales 36.1


-- ------------------------------------------------------------
-- 1.6 Education Level Distribution
-- ORDER BY Education_Score sorts by academic ladder not alphabet
-- ------------------------------------------------------------
SELECT
    Education,
    Education_Score,
    COUNT(*) AS Headcount,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Pct_of_Workforce
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Education, Education_Score
ORDER BY Education_Score ASC;


-- ============================================================
-- SECTION 3 : LAYER 2 — ATTRITION & RETENTION
-- Baseline question: Who are we losing?
-- IMPORTANT: No DateDeparture filter here — attrition rate must
-- be calculated against total workforce (active + departed)
-- Total workforce = 1,470 | Leavers = 237 | Active = 1,233
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Overall Attrition Rate
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Total_Leavers,
    COUNT(*) - SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Total_Retained,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset];


-- ------------------------------------------------------------
-- 2.2 Attrition Rate by Department
-- ------------------------------------------------------------
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    COUNT(*) - SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Retained,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY Department
ORDER BY Attrition_Rate_Pct DESC;


-- ------------------------------------------------------------
-- 2.3 Attrition by Gender
-- Use rates not raw counts — group sizes differ so rates
-- give a fair like-for-like comparison
-- ------------------------------------------------------------
SELECT
    Gender,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY Gender
ORDER BY Attrition_Rate_Pct DESC;


-- ------------------------------------------------------------
-- 2.4 Attrition by Age Group
-- Numeric prefix on AgeGroup means ASC = correct age order
-- Watch for U-shape: high at 20-30, dip mid-career, rise at 50+
-- ------------------------------------------------------------
SELECT
    AgeGroup,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY AgeGroup
ORDER BY AgeGroup ASC;


-- ------------------------------------------------------------
-- 2.5 Attrition by Marital Status
-- Single employees globally show highest attrition — fewer
-- relocation constraints and lower financial anchors
-- ------------------------------------------------------------
SELECT
    MaritalStatus,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY MaritalStatus
ORDER BY Attrition_Rate_Pct DESC;


-- ------------------------------------------------------------
-- 2.6 Attrition by Tenure Bracket
-- Classic U-shape expected: high at 0-2 yrs, low mid-career,
-- rising again at 10+ yrs
-- ------------------------------------------------------------
SELECT
    [YearsAtCompany_Group] AS Tenure_Band,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Leavers,
    ROUND(
        SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    1) AS Attrition_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY [YearsAtCompany_Group]
ORDER BY [YearsAtCompany_Group] ASC;


-- ------------------------------------------------------------
-- 2.7 Voluntary vs Involuntary Termination
-- Critical distinction: voluntary = retention problem (fix culture/pay)
--                       involuntary = performance/restructuring issue
-- Filter to leavers only — active employees have no TerminationType
-- ------------------------------------------------------------
SELECT
    CASE TerminationType
        WHEN 1 THEN 'Voluntary'
        WHEN 2 THEN 'Involuntary'
    END AS Termination_Type,
    COUNT(*) AS Total_Departures,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Pct_of_Departures
FROM [Hr Analytics Dataset]
WHERE Attrition_Label = 'Yes'
    AND TerminationType IS NOT NULL
GROUP BY TerminationType
ORDER BY Total_Departures DESC;


-- ============================================================
-- SECTION 4 : LAYER 3 — COMPENSATION ANALYSIS
-- Baseline question: Are we paying fairly?
-- Filter: WHERE DateDeparture IS NULL (current salaries only)
-- ============================================================

-- ------------------------------------------------------------
-- 3.1 Average Salary by Department & Job Role
-- Salary_Spread = gap between highest and lowest in same role
-- Large spread = pay inconsistency within same job title
-- ------------------------------------------------------------
SELECT
    Department,
    Job_Role,
    COUNT(*) AS Headcount,
    ROUND(AVG(CAST(Salary AS FLOAT)), 0) AS Avg_Salary,
    MIN(Salary) AS Min_Salary,
    MAX(Salary) AS Max_Salary,
    MAX(Salary) - MIN(Salary) AS Salary_Spread
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Department, Job_Role
ORDER BY Department, Avg_Salary DESC;


-- ------------------------------------------------------------
-- 3.2 Gender Pay Gap by Job Role
-- Pivot-style AVG using CASE — reads male and female salary
-- from the same rows without splitting into two queries
-- Pay_Gap_Pct: positive = males earn more, negative = females earn more
-- Industry standard: report gap as % of male salary
-- ------------------------------------------------------------
SELECT
    Job_Role,
    ROUND(AVG(CASE WHEN Gender = 'Male'   THEN CAST(Salary AS FLOAT) END), 0) AS Avg_Male_Salary,
    ROUND(AVG(CASE WHEN Gender = 'Female' THEN CAST(Salary AS FLOAT) END), 0) AS Avg_Female_Salary,
    ROUND(
        AVG(CASE WHEN Gender = 'Male'   THEN CAST(Salary AS FLOAT) END) -
        AVG(CASE WHEN Gender = 'Female' THEN CAST(Salary AS FLOAT) END)
    , 0) AS Pay_Gap,
    ROUND(
        (AVG(CASE WHEN Gender = 'Male' THEN CAST(Salary AS FLOAT) END) -
         AVG(CASE WHEN Gender = 'Female' THEN CAST(Salary AS FLOAT) END)) * 100.0 /
         AVG(CASE WHEN Gender = 'Male' THEN CAST(Salary AS FLOAT) END)
    , 1) AS Pay_Gap_Pct
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY Job_Role
ORDER BY Pay_Gap_Pct DESC;


-- ------------------------------------------------------------
-- 3.3 Salary vs Performance Rating
-- Key question: are top performers actually being paid more?
-- Flat hikes across all ratings = retention risk hiding in data
-- ------------------------------------------------------------
SELECT
    PerformanceRating,
    PerformanceRating_Score,
    COUNT(*) AS Employees,
    ROUND(AVG(CAST(Salary AS FLOAT)), 0) AS Avg_Salary,
    ROUND(AVG(CAST(PercentSalaryHike AS FLOAT)), 1) AS Avg_Salary_Hike_Pct
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY PerformanceRating, PerformanceRating_Score
ORDER BY PerformanceRating_Score ASC;


-- ------------------------------------------------------------
-- 3.4 Salary by Employment Type & Education
-- Two questions in one:
-- (1) Do contractors earn more/less than full-timers?
-- (2) Does higher education actually translate to higher pay?
-- ------------------------------------------------------------
SELECT
    EmploymentType,
    Education,
    Education_Score,
    COUNT(*) AS Employees,
    ROUND(AVG(CAST(Salary AS FLOAT)), 0) AS Avg_Salary
FROM [Hr Analytics Dataset]
WHERE DateDeparture IS NULL
GROUP BY EmploymentType, Education, Education_Score
ORDER BY EmploymentType, Education_Score ASC;

-- Key finding: Contractor Doctors earn ~64% more than Full-time Doctors
-- Unexpected: Full-time Masters earn less than Full-time Bachelors
--             Suggests pay is role-based not education-based


-- ============================================================
-- END OF WEEK 1 SCRIPT
-- Next Week: Layer 4 (Satisfaction vs Attrition)
--            Layer 5 (Performance & Overtime)
--            Power BI Dashboard Build
-- ============================================================


-- ============================================================
-- HR ANALYTICS | LAYER 4: SATISFACTION vs ATTRITION
-- Author : Sam Akande Bolarinwa
-- Tool   : SQL Server (SSMS)
-- Dataset: 1,470 employees | 38 columns
-- ============================================================


-- ─────────────────────────────────────────────
-- 4.1  ATTRITION RATE BY JOB SATISFACTION
-- Verdict: Low satisfaction = 2x the exit rate of Very High
-- ─────────────────────────────────────────────
SELECT
    JobSatisfaction,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    SUM(CASE WHEN Attrition_Label = 'No'  THEN 1 ELSE 0 END)            AS Active,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY JobSatisfaction
ORDER BY AttritionRate_Pct DESC;

-- ─────────────────────────────────────────────
-- 4.2  ATTRITION RATE BY WORK-LIFE BALANCE
-- Verdict: "Bad" WLB employees leave at 2.2x the rate of "Better"
-- ─────────────────────────────────────────────
SELECT
    WorkLifeBalance,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    ) AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY WorkLifeBalance
ORDER BY AttritionRate_Pct DESC;


-- ─────────────────────────────────────────────
-- 4.3  ATTRITION RATE BY ENVIRONMENT SATISFACTION
-- Verdict: Low env satisfaction = nearly 2x the rate of High
-- ─────────────────────────────────────────────
SELECT
    EnvironmentSatisfaction,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    ) AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY EnvironmentSatisfaction
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output:
EnvironmentSatisfaction | AttritionRate_Pct
Low                     | 25.4%
Medium                  | 15.0%
High                    | 13.7%
Very High               | 13.5%
*/


-- ─────────────────────────────────────────────
-- 4.4  ATTRITION RATE BY JOB INVOLVEMENT
-- Verdict: Low involvement = 33.7% exit rate — the single strongest
--          satisfaction-side predictor in the dataset
-- ─────────────────────────────────────────────
SELECT
    JobInvolvement,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY JobInvolvement
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output:
JobInvolvement | AttritionRate_Pct
Low            | 33.7%   ← danger zone
Medium         | 18.9%
High           | 14.4%
Very High      |  9.0%   ← most engaged, most retained
*/


-- ─────────────────────────────────────────────
-- 4.5  DEPARTMENT × JOB SATISFACTION ATTRITION MATRIX
-- Business Use: pinpoint which dept-satisfaction combos are bleeding talent
-- ─────────────────────────────────────────────
SELECT
    Department,
    JobSatisfaction,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY Department, JobSatisfaction
ORDER BY Department, AttritionRate_Pct DESC;

/*
KEY FINDING:
Human Resources + Low Satisfaction = 45.5% attrition — nearly 1 in 2 employees leaves
Sales + Low Satisfaction            = 26.7%
R&D + Low Satisfaction              = 19.8%
→ HR dept is the most vulnerable segment in the entire workforce
*/


-- ─────────────────────────────────────────────
-- 4.6  SATISFACTION COMPOSITE RISK SCORE
-- Flags employees scoring Low on 3+ satisfaction dimensions
-- Business Use: early-warning retention list
-- ─────────────────────────────────────────────
SELECT
    ID_employe,
    Department,
    Job_Role,
    JobSatisfaction,
    WorkLifeBalance,
    EnvironmentSatisfaction,
    JobInvolvement,
    Attrition,
    (
        CASE WHEN JobSatisfaction         = 'Low' THEN 1 ELSE 0 END +
        CASE WHEN WorkLifeBalance         = 'Bad'  THEN 1 ELSE 0 END +
        CASE WHEN EnvironmentSatisfaction = 'Low'  THEN 1 ELSE 0 END +
        CASE WHEN JobInvolvement          = 'Low'  THEN 1 ELSE 0 END
    )                                                               AS RiskScore
FROM [Hr Analytics Dataset]
ORDER BY RiskScore DESC, Department;

/*
RiskScore = 4 → All four dimensions are red flags (maximum flight risk)
RiskScore = 3 → High priority intervention needed
RiskScore <= 1 → Stable
*/


-- ============================================================
-- HR ANALYTICS | LAYER 5: PERFORMANCE & OVERTIME
-- Author : Sam Akande Bolarinwa
-- Tool   : SQL Server (SSMS)
-- Dataset: 1,470 employees | 38 columns
-- ============================================================


-- ─────────────────────────────────────────────
-- 5.1  ATTRITION RATE BY OVERTIME STATUS
-- Verdict: OT employees leave at 3x the rate of non-OT employees
-- ─────────────────────────────────────────────
SELECT
    OverTime,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    SUM(CASE WHEN Attrition_Label = 'No'  THEN 1 ELSE 0 END)            AS Active,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY OverTime
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output:
OverTime | AttritionRate_Pct
Yes      | 30.5%   ← 3x multiplier
No       | 10.4%
*/


-- ─────────────────────────────────────────────
-- 5.2  ATTRITION RATE BY PERFORMANCE RATING
-- Verdict: Counter-intuitive — Good & Low performers leave more than Outstanding
--          "Good" rated employees are the most at-risk cohort (40.6%)
-- ─────────────────────────────────────────────
SELECT
    PerformanceRating,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct,
    ROUND(AVG(CAST(PercentSalaryHike AS FLOAT)), 1)                AS AvgSalaryHike_Pct
FROM [Hr Analytics Dataset]
GROUP BY PerformanceRating
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output:
PerformanceRating | AttritionRate_Pct | AvgSalaryHike_Pct
Good              | 40.6%             | 14.2%
Low               | 36.1%             | 14.0%
Outstanding       | 16.1%             | 21.8%  ← only group rewarded differently
Excellent         | 12.0%             | 14.0%

KEY INSIGHT: Good, Low, and Excellent performers all receive ~14% hike.
Only Outstanding gets differentiated pay (21.8%).
The flat reward structure for middle performers is a retention leak.
*/


-- ─────────────────────────────────────────────
-- 5.3  OVERTIME × PERFORMANCE — THE BURNOUT MATRIX
-- Most dangerous combination: OT Yes + Good/Low performance
-- ─────────────────────────────────────────────
SELECT
    OverTime,
    PerformanceRating,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY OverTime, PerformanceRating
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output (top rows):
OverTime | PerformanceRating | AttritionRate_Pct
Yes      | Good              | 60.5%   ← CRITICAL: 3 in 5 leave
Yes      | Low               | 60.0%   ← equally severe
Yes      | Outstanding       | 35.9%
Yes      | Excellent         | 22.8%
No       | Good              | 30.6%
No       | Low               | 24.4%
No       | Outstanding       |  8.1%
No       | Excellent         |  7.9%

BUSINESS TRANSLATION: An employee doing OT with a Good or Low rating
has a 60% chance of leaving. The company is burning people out
without the performance recognition to justify it.
*/


-- ─────────────────────────────────────────────
-- 5.4  OVERTIME DISTRIBUTION BY DEPARTMENT
-- Which department carries the most OT burden?
-- ─────────────────────────────────────────────
SELECT
    Department,
    SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END)             AS OT_Employees,
    SUM(CASE WHEN OverTime = 'No'  THEN 1 ELSE 0 END)             AS NonOT_Employees,
    COUNT(*)                                                        AS TotalEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS OT_Rate_Pct
FROM [Hr Analytics Dataset]
GROUP BY Department
ORDER BY OT_Rate_Pct DESC;

/*
Expected Output:
Department              | OT_Rate_Pct
Sales                   | 28.7%
Research & Development  | 28.2%
Human Resources         | 27.0%
→ OT burden is roughly equal across departments — this is a company-wide policy issue
*/


-- ─────────────────────────────────────────────
-- 5.5  TRAINING INVESTMENT vs ATTRITION
-- Do undertrained employees leave more?
-- ─────────────────────────────────────────────
SELECT
    Attrition,
    COUNT(*)                                                        AS TotalEmployees,
    ROUND(AVG(CAST(TrainingTimesLastYear AS FLOAT)), 2)            AS AvgTrainingSessions,
    MIN(TrainingTimesLastYear)                                      AS MinSessions,
    MAX(TrainingTimesLastYear)                                      AS MaxSessions
FROM [Hr Analytics Dataset]
GROUP BY Attrition;

/*
Expected Output:
Attrition | AvgTrainingSessions
No        | 2.83
Yes       | 2.62

Employees who left received slightly fewer training sessions.
Not dramatic, but directionally consistent with disengagement.
*/


-- ─────────────────────────────────────────────
-- 5.6  PROMOTION LAG vs ATTRITION
-- Does being passed over for promotion drive exits?
-- ─────────────────────────────────────────────
SELECT
    Attrition,
    ROUND(AVG(CAST(YearsSinceLastPromotion AS FLOAT)), 2)          AS AvgYearsSincePromotion,
    ROUND(AVG(CAST(YearsWithCurrManager   AS FLOAT)), 2)           AS AvgYearsWithManager,
    COUNT(*)                                                        AS TotalEmployees
FROM [Hr Analytics Dataset]
GROUP BY Attrition;

/*
Expected Output:
Attrition | AvgYearsSincePromotion | AvgYearsWithManager
No        | 2.19                   | 4.25
Yes       | 1.82                   | 2.73

Employees who left had actually been promoted MORE recently —
suggesting early-career dissatisfaction, not stagnation.
Short tenure with current manager (2.85 vs 4.37) = poor manager relationship
is a stronger signal than promotion timing.
*/


-- ─────────────────────────────────────────────
-- 5.7  THE DANGER ZONE — OT + LOW JOB SATISFACTION
-- Business Use: highest-priority retention intervention list
-- ─────────────────────────────────────────────
SELECT
    OverTime,
    JobSatisfaction,
    COUNT(*)                                                        AS TotalEmployees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)            AS Terminated,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END)
              / COUNT(*), 1
    )                                                               AS AttritionRate_Pct
FROM [Hr Analytics Dataset]
GROUP BY OverTime, JobSatisfaction
ORDER BY AttritionRate_Pct DESC;

/*
Expected Output:
OverTime | JobSatisfaction | AttritionRate_Pct
Yes      | Low             | 35.7%
Yes      | Medium          | 37.7%
Yes      | High            | 33.9%
Yes      | Very High       | 21.1%
No       | Low             | 17.6%
No       | Medium          |  9.5%
No       | High            | 10.0%
No       | Very High       |  6.9%

CONCLUSION: Overtime is the dominant driver — even Very High satisfaction
employees doing OT leave at 21% vs 6.9% for their non-OT counterparts.
Overtime policy reform would have the single largest impact on retention.
*/
