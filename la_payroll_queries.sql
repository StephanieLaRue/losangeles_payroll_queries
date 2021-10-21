USE la_payroll;

-- count of employees per department
SELECT 
    Year, DepartmentTitle, COUNT(*) AS Employees
FROM
    losangeles_payroll
GROUP BY Year , DepartmentTitle;

-- salary comparisons for all years and job titles
SELECT 
	Year,
    JobClassTitle,
    FORMAT(MAX(TotalPayments),'C') HighestSalary,
    FORMAT(MIN(TotalPayments),'C') LowestSalary,
    FORMAT(AVG(TotalPayments),'C') AvgSalary
FROM
    losangeles_payroll 
GROUP BY Year, JobClassTitle
ORDER BY Year, JobClassTitle;

-- salary comparisons by department for all years
SELECT 
	Year,
	DepartmentTitle,
    FORMAT(MAX(TotalPayments),'C') HighestPaid, 
    FORMAT(MIN(TotalPayments),'C') LowestPaid, 
    FORMAT(AVG(TotalPayments),'C') AvgPaid
    FROM
        losangeles_payroll
    GROUP BY Year, DepartmentTitle
	ORDER BY Year;

-- projected spending
SELECT 
	Year,
	FORMAT(SUM(ProjectedAnnualSalary),'C') ProjectedSalaries
FROM losangeles_payroll
GROUP BY Year
ORDER BY Year desc;

-- spending by department, base pay only
SELECT
	Year,
	DepartmentTitle, 
	FORMAT(SUM(BasePay),'c') BasePay
FROM losangeles_payroll
GROUP BY Year, DepartmentTitle
ORDER BY Year DESC;

-- differences in qtrly spending for each year
SELECT
	Year, 
    FORMAT(SUM(Q1Payments),'C') Q1Payments,
    FORMAT(SUM(Q2Payments),'C') Q2Payments,
    FORMAT(SUM(Q3Payments),'C') Q3Payments,
	FORMAT(SUM(Q4Payments),'C') Q4Payments
FROM losangeles_payroll
GROUP BY Year
ORDER BY Year;

-- qrtly spending by department for each year
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(Q1Payments),'C') Q1Payments,
    FORMAT(SUM(Q2Payments),'C') Q2Payments,
    FORMAT(SUM(Q3Payments),'C') Q3Payments,
	FORMAT(SUM(Q4Payments),'C') Q4Payments
FROM losangeles_payroll
GROUP BY Year, DepartmentTitle
ORDER BY Year;

-- avg projected salary by department 
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(AVG(ProjectedAnnualSalary),'C') AS ProjectedAnnualSalary
FROM losangeles_payroll
WHERE ProjectedAnnualSalary > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year;

-- avg overtime pay by department
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(AVG(OvertimePay),'C') AS Avg_Overtime_Pay
FROM losangeles_payroll
WHERE OvertimePay > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle; 

-- total overtime pay by department
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(OvertimePay),'C') AS Total_Overtime_Pay
FROM losangeles_payroll
WHERE OvertimePay > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- top 3 departments with highest overtime pay for each year
SELECT 
	Year, DepartmentTitle, FORMAT(Total,'C') AS OvertimePay
    FROM(SELECT Year, DepartmentTitle, SUM(OvertimePay) AS Total, 
		ROW_NUMBER() OVER(PARTITION BY Year ORDER BY Year, SUM(OvertimePay) DESC) Tops
	FROM losangeles_payroll WHERE OvertimePay > 0  
    GROUP BY Year, DepartmentTitle ) dd
    WHERE Tops <= 3
ORDER BY Year;

-- department with highest overtime pay 
SELECT 
	Year, DepartmentTitle, FORMAT(Total,'C') AS OvertimePay
    FROM(SELECT Year, DepartmentTitle, SUM(OvertimePay) AS Total, 
		ROW_NUMBER() OVER(PARTITION BY Year ORDER BY Year, SUM(OvertimePay) DESC) Tops
	FROM losangeles_payroll WHERE OvertimePay > 0  
    GROUP BY Year, DepartmentTitle ) dd
    WHERE Tops <= 1
ORDER BY Year;

-- base pay & over time by department
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(BasePay),'C') AS BasePay,
    FORMAT(SUM(OvertimePay),'C') AS OvertimePaid,
    FORMAT(SUM(TotalPayments),'C') AS TotalPaid
FROM losangeles_payroll
WHERE TotalPayments > 0 AND OvertimePay > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- overtime % of total paid 
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(BasePay),'C') AS BasePay,
    FORMAT(SUM(OvertimePay),'C') AS OvertimePaid,
    FORMAT(SUM(TotalPayments),'C') AS TotalPaid,
    FORMAT(SUM(OvertimePay)/SUM(TotalPayments)*100,'N') AS PercentOvertime
FROM losangeles_payroll
WHERE TotalPayments > 0 AND OvertimePay > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- projected vs actual salary totals
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(ProjectedAnnualSalary),'C') AS ProjectedAnnualSalary,
    FORMAT(SUM(TotalPayments),'C') AS ActualPaid,
    FORMAT(SUM(ProjectedAnnualSalary-TotalPayments),'C') Difference
FROM losangeles_payroll
WHERE TotalPayments > 0 AND ProjectedAnnualSalary > 0
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- % increase from projected to actual
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(ProjectedAnnualSalary),'C') AS ProjectedAnnualSalary,
    FORMAT(SUM(TotalPayments),'C') AS ActualPaid,
   FORMAT(((SUM(ProjectedAnnualSalary-TotalPayments))/SUM(ProjectedAnnualSalary))*100,'N') Percent_Difference
FROM losangeles_payroll
WHERE TotalPayments <> 0 AND ProjectedAnnualSalary <> 0 
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- other payments
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(TotalPayments),'C') AS ActualPaid,
    FORMAT(SUM(PaymentsOverBasePay),'C') OtherPayments,
    FORMAT(SUM(TotalPayments)/SUM(PaymentsOverBasePay),'N') PercentOtherPayments
FROM losangeles_payroll
WHERE TotalPayments <> 0 AND OvertimePay <> 0 
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- % of pay from overtime and other payments
-- vs base pay by department
SELECT
	Year, 
    DepartmentTitle,
    FORMAT(SUM(TotalPayments),'C') AS ActualPaid,
    FORMAT(SUM(OvertimePay),'C') Overtime,
    FORMAT(SUM(PaymentsOverBasePay),'C') OtherPayments,
    FORMAT((SUM(OvertimePay)+SUM(PaymentsOverBasePay))/SUM(TotalPayments)*100,'N') PercentOfActualPay
FROM losangeles_payroll
WHERE TotalPayments <> 0 AND OvertimePay <> 0 
GROUP BY Year, DepartmentTitle
ORDER BY Year, DepartmentTitle;

-- full time vs part time avg pay 
-- and by department
SELECT
	Year, 
    EmploymentType,
    FORMAT(AVG(TotalPayments),'C') AS AvgPaid
FROM losangeles_payroll
WHERE TotalPayments <> 0
GROUP BY Year, EmploymentType
ORDER BY Year, EmploymentType;
-- by department
SELECT
	Year, 
    EmploymentType,
    DepartmentTitle,
    FORMAT(AVG(TotalPayments),'C') AS AvgPaid
FROM losangeles_payroll
WHERE TotalPayments <> 0
GROUP BY Year, DepartmentTitle, EmploymentType
ORDER BY Year, DepartmentTitle, EmploymentType, AvgPaid;

-- job titles of 5 lowest paid and highest paid employees in each year
SELECT
	Year, JobClassTitle, 
	FORMAT(TotalPayments,'C') TotalPayment, 
	SalaryRank 
FROM(
	(SELECT 
		ROW_NUMBER() OVER(PARTITION BY Year ORDER BY Year, TotalPayments DESC) Tops,
		Year, JobClassTitle, 
		TotalPayments, 
		'Highest' AS SalaryRank
	FROM
		losangeles_payroll
	WHERE 
		TotalPayments > 0
	) 
	UNION ALL 
	(SELECT 
		ROW_NUMBER() OVER(PARTITION BY Year ORDER BY Year, TotalPayments) Tops, 
		Year, JobClassTitle, 
		TotalPayments, 
		'Lowest' AS SalaryRank
	FROM
		losangeles_payroll
	WHERE 
		TotalPayments > 0
	)) low_high_payments
WHERE 
	Tops <=3
ORDER BY 
	Year, SalaryRank;



