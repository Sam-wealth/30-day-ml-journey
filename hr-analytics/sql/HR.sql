SELECT *
FROM [Hr Analytics Dataset],
;
--DATA CLEANING
--Step 1: Fix the 3 mismatched Age values
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

--Step 2: Decide what blank StockOption means, then fill it in
UPDATE [Hr Analytics Dataset]
SET StockOption = 'None'
WHERE StockOption IS NULL;

--Step 3: Add a numeric scale for the ordinal text fields
ALTER TABLE [Hr Analytics Dataset] ADD JobSatisfaction_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD EnvironmentSatisfaction_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD JobInvolvement_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD WorkLifeBalance_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD PerformanceRating_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD Education_Score INT;
ALTER TABLE [Hr Analytics Dataset] ADD StockOption_Score INT;

--due to an error that happened I have to reassign the ordinal texts back
UPDATE [Hr Analytics Dataset]
SET JobSatisfaction = CASE Jobsatisfaction_score
       
       --DETECTING THE ERROR
SELECT DISTINCT JobSatisfaction
FROM [Hr Analytics Dataset]
ORDER BY JobSatisfaction;

SELECT DISTINCT JobSatisfaction, JobSatisfaction_Score
FROM [Hr Analytics Dataset];
        --SOLVING THE ERROR
UPDATE [Hr Analytics Dataset]
SET JobSatisfaction_Score = JobSatisfaction;

UPDATE [Hr Analytics Dataset]
SET JobSatisfaction = CASE JobSatisfaction                      
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END;


    --VERIFYING THE CORRECTION
    SELECT Distinct JobSatisfaction
    From [Hr Analytics Dataset]
    Order by JobSatisfaction;

    SELECT distinct Jobsatisfaction_Score
    FROM [Hr Analytics Dataset]
    Order by JobSatisfaction_score;

    --Now correct it for all scores columns
UPDATE [Hr Analytics Dataset]
SET JobInvolvement_Score = JobInvolvement;
UPDATE [Hr Analytics Dataset]
SET Environmentsatisfaction_Score = Environmentsatisfaction;
UPDATE [Hr Analytics Dataset]
SET WorkLifeBalance_Score = WorkLifeBalance;
UPDATE [Hr Analytics Dataset]
SET PerformanceRating_Score = PerformanceRating;

UPDATE [Hr Analytics Dataset]
SET PerformanceRating_Score = PerformanceRating;
UPDATE [Hr Analytics Dataset]
SET Education_Score = Education;
UPDATE [Hr Analytics Dataset]
SET StockOption_Score = StockOption;

UPDATE [Hr Analytics Dataset]
SET 
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

UPDATE [Hr Analytics Dataset]
   SET Education_Score = CASE Education
        WHEN 'Below College' THEN 1
        WHEN 'College'       THEN 2
        WHEN 'Bachelor'      THEN 3
        WHEN 'Master'        THEN 4
        WHEN 'Doctor'        THEN 5
    END;

UPDATE [Hr Analytics Dataset]
SET 
    Education_Score         = Education,
    JobInvolvement_Score    = JobInvolvement,
    WorkLifeBalance_Score   = WorkLifeBalance,
    PerformanceRating_Score = PerformanceRating;
UPDATE [Hr Analytics Dataset]
SET StockOption_Score       = StockOption;

UPDATE [Hr Analytics Dataset]
SET 
    Education = CASE Education
        WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
    END,

    JobInvolvement = CASE JobInvolvement
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END,

    WorkLifeBalance = CASE WorkLifeBalance
        WHEN 1 THEN 'Bad'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Better'
        WHEN 4 THEN 'Best'
    END,

    PerformanceRating = CASE PerformanceRating
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Excellent'
        WHEN 4 THEN 'Outstanding'
    END;

UPDATE [Hr Analytics Dataset]
SET     StockOption = CASE StockOption
        WHEN 0 THEN 'None'
        WHEN 1 THEN 'Low' 
        WHEN 2  THEN 'Mid'
        WHEN 3 THEN 'High'
    END;

SELECT DISTINCT
    Education,              Education_Score,
    JobInvolvement,         JobInvolvement_Score,
    WorkLifeBalance,        WorkLifeBalance_Score,
    PerformanceRating,      PerformanceRating_Score,
    StockOption,            StockOption_Score
FROM [Hr Analytics Dataset]
ORDER BY Education_Score;

 
--FULL ANALYSIS
    --LAYER 1 - WORKFORCE COMPOSITION
        --Layer 1.1 — Headcount by Department
        SELECT 
        Department,
        COUNT (*) AS Headcount
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture is NULL
        GROUP BY Department
        ORDER BY Headcount DESC;

        --Layer 1.2 — Headcount by Employment Type
        SELECT
        EmploymentType,
        COUNT(*) AS Headcount,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Percentage
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture IS NULL
        GROUP BY EmploymentType
        ORDER BY Headcount DESC;

        --Layer 1.3 — Gender Distribution by Department
        SELECT
        Department,
        Gender,
        COUNT(*) AS Headcount,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Department), 1) AS Pct_Within_Dept
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture IS NULL
        GROUP BY Department, Gender
        ORDER BY Department, Headcount DESC;

        --Layer 1.4 — Age Profile by Department
        SELECT
        Department,
        AgeGroup,
        COUNT(*) AS Headcount,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY Department), 1) AS Pct_Within_Dept
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture IS NULL
        GROUP BY Department, AgeGroup
        ORDER BY Department, AgeGroup DESC;

        --Layer 1.4.1 — average age per department in one line:
        SELECT 
            Department,
            ROUND(AVG(CAST(Age As FLOAT)), 1) As Avg_Age,
            MIN(Age) AS Youngest,
            MAX(Age) AS Oldest
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture IS NULL
        GROUP BY Department
        ORDER BY Avg_Age DESC; 

        --Layer 1.5 — Education Level Distribution
        SELECT
            Education,
            Education_Score,
            COUNT(*) AS Headcount,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS Pct_of_Workforce
        FROM [Hr Analytics Dataset]
        WHERE DateDeparture IS NULL
        GROUP BY Education, Education_Score
        ORDER BY Education_Score ASC;

        -- CrossThis number should match across all 5 queries above
            SELECT COUNT(*) AS Total_Active_Employees
            FROM [Hr Analytics Dataset]
            WHERE DateDeparture IS NULL;

--LAYER 2: ATTRITION 


ALTER TABLE [Hr Analytics Dataset]
DROP COLUMN Attrition_score;

ALTER TABLE [Hr Analytics Dataset]
ADD Attrition_Label AS (CASE WHEN Attrition = 1 THEN 'Yes' ELSE 'No' END);

SELECT DISTINCT Attrition
FROM [Hr Analytics Dataset];

--Attrittion by Overall
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    SUM(CASE WHEN Attrition_label = 'No' THEN 1 ELSE 0 END) AS retained,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM [Hr Analytics Dataset];

--Layer 2.2 — Attrition Rate by Department
SELECT
    Department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
    FROM [Hr Analytics Dataset]
    GROUP BY Department
    ORDER BY attrition_rate_pct;

--Layer 2.3     Attrition by Gender
    SELECT
    Gender,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
    FROM [Hr Analytics Dataset]
    GROUP BY Gender
    ORDER BY attrition_rate_pct;

--Layer 2.4 Attrition by AgeGroup
    SELECT
    AgeGroup,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
    FROM [Hr Analytics Dataset]
    GROUP BY AgeGroup
    ORDER BY AgeGroup ASC;

--Layer 2.5 Attrition by Marital Status
    SELECT
    MaritalStatus,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
    FROM [Hr Analytics Dataset]
    GROUP BY MaritalStatus
    ORDER BY attrition_rate_pct DESC; --TO KNOW HIGHEST-LOWEST RATE

--Layer 2.6 Attrition by Tenure Bracket
    SELECT
    [YearsAtCompany_Group] AS Tenure_band,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition_Label = 'Yes' THEN 1 ELSE 0 END) AS attrited,
    ROUND(SUM(CASE WHEN Attrition_label = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
    FROM [Hr Analytics Dataset]
    GROUP BY YearsAtCompany_Group
    ORDER BY attrition_rate_pct;

--Layer 2.7 Voluntary vs Involuntary Termination
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

--Layer 3 Compensation Analysis HR reviews
   --Average Salary by Department and Job role
   -- Where is money being spent and is pay consistent within roles?
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



SELECT *
FROM [Hr Analytics Dataset];