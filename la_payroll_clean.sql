USE la_payroll;

SELECT * FROM losangeles_payroll;
-- replace missing job titles
UPDATE tableA
SET 
    tableA.JobClassTitle = ISNULL(tableA.JobClassTitle,
            tableB.JobClassTitle)
FROM losangeles_payroll AS tableA
	JOIN
		losangeles_payroll AS tableB 
		ON tableA.JobClass = tableB.JobClass 
WHERE
    tableA.JobClassTitle IS NULL;

-- replace missing job class values
UPDATE tableA
SET 
    tableA.JobClass = ISNULL(tableA.JobClass, tableB.JobClass)
FROM losangeles_payroll AS tableA
        JOIN
    losangeles_payroll AS tableB ON tableA.JobClassTitle = tableB.JobClassTitle 
WHERE
    tableA.JobClass IS NULL;

-- delete empty records
DELETE 
FROM 
	losangeles_payroll 
WHERE
    ID IS NULL;

-- delete record with no other values
DELETE 
FROM 
	losangeles_payroll 
WHERE
    Year IS NULL 
	AND TotalPayments IS NULL 
	AND RecordNumber IS NULL;

-- update records without benefit plans to N/A
UPDATE losangeles_payroll 
SET 
    BenefitsPlan = (CASE
        WHEN BenefitsPlan IS NULL THEN 'N/A'
        ELSE BenefitsPlan
    END);

-- table contains fields with same id
-- other identifiers share too many like values with other records
ALTER TABLE losangeles_payroll
ADD temp_unique_id INT IDENTITY(1,1) PRIMARY KEY;

-- delete duplicates
WITH cte AS (
	SELECT 
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY temp_unique_id) AS rows
    FROM
        losangeles_payroll 
) 
DELETE FROM cte WHERE rows > 1;

SELECT * FROM losangeles_payroll;

-- dropping temp unique id column
ALTER TABLE losangeles_payroll
DROP CONSTRAINT [PK__losangel__B596A9BA087BC02E];

ALTER TABLE losangeles_payroll
DROP COLUMN temp_unique_id;

-- modifying ID column to avoid future duplicate IDs
ALTER TABLE losangeles_payroll
ALTER COLUMN ID INT NOT NULL;

ALTER TABLE losangeles_payroll
ADD CONSTRAINT pk_id PRIMARY KEY (ID);


