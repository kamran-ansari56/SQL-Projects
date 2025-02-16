-- SELECTING THE TABLE
SELECT * FROM laptop;

-- CREATING A BACKUP TABLE AND INSERT DATA
CREATE TABLE laptop_backup SELECT * FROM laptop;

-- CHECK FEILD PARAMETERS
DESCRIBE laptop;

-- CHECK NUMBER OF ROWS
SELECT COUNT(*) FROM laptop;

-- CHECK MEMORY CONSUMPTION OF DATA
SELECT * FROM information_schema.tables
WHERE table_schema = 'mobile' and table_name = 'laptop';

-- CHECK DATA LENGTH IN KB
SELECT data_length/1024 FROM information_schema.tables
WHERE table_schema = 'mobile' AND table_name = 'laptop';

-- REMOVE UNWANTED COLUMNS
ALTER TABLE laptop
DROP COLUMN `Unnamed: 0`;

-- ADD PRIMARY KEY TO THE TABLE
ALTER TABLE laptop
ADD COLUMN phone_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- TURN OFF SQL SAFE UPDATE MODE
SET sql_safe_updates = 0;

-- DROP NULL VALUES
DELETE FROM laptop where company NOT IN 
('Apple','HP','Acer','Asus','Dell','Lenovo','Chuwi','MSI','Microsoft','Toshiba','Huawei','Xiaomi','Vero','Razer','Mediacom','Samsung','Google','Fujitsu','LG');

-- CHECKING DUPLICATE DATA
SELECT Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu, OpSys,Weight,Price, COUNT(*)
FROM laptop
GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu, OpSys,Weight,Price
HAVING COUNT(*) > 1 ;

-- UPDATING RELEVANT DATA TYPES AND REDUCE FILE SIZE
ALTER TABLE laptop
MODIFY COLUMN Inches DECIMAL (10,2);

UPDATE laptop
SET Ram = REPLACE(Ram, 'GB',' ');
ALTER TABLE laptop MODIFY Ram INT;

UPDATE laptop
SET Weight = REPLACE(Weight, 'kg',' ');
ALTER TABLE laptop MODIFY Weight DECIMAL (10,2);

UPDATE laptop
SET OpSys = CASE
	WHEN OpSys LIKE '%mac%' THEN 'macos'
	WHEN OpSys LIKE '%windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'Other'
END;

-- ADD NEW COLUMNS TO SPLIT GPU COLUMN
ALTER TABLE laptop
ADD COLUMN gpu_brand VARCHAR(50) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(50) AFTER gpu_brand;

-- INSERT DATA IN NEW COLUMNS
UPDATE laptop
SET gpu_brand = SUBSTRING_INDEX(Gpu,' ',1);

UPDATE laptop
SET Gpu = REPLACE(Gpu,gpu_brand,' ');

UPDATE laptop
SET gpu_name = Gpu;

ALTER TABLE laptop
DROP Gpu;

-- ADD NEW COLUMNS TO SPLIT CPU COLUMN
ALTER TABLE laptop
ADD COLUMN cpu_brand VARCHAR(50) AFTER Cpu,
ADD COLUMN cpu_speed DECIMAL(20,1) AFTER cpu_name;

UPDATE laptop
SET cpu_brand = SUBSTRING_INDEX(Cpu,' ', 1);

UPDATE laptop
SET cpu_speed = SUBSTRING_INDEX(Cpu,' ', -1);

ALTER TABLE laptop
DROP COLUMN Cpu;

-- ADD NEW COLUMNS TO SPLIT SCREEN RESOLUTION COLUMN
ALTER TABLE laptop
ADD COLUMN resolution_width INT AFTER ScreenResolution,
ADD COLUMN resolution_height INT AFTER resolution_width;

SELECT ScreenResolution, 
SUBSTRING_INDEX(ScreenResolution,' ',-1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1)  
FROM laptop;

UPDATE laptop
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);

ALTER TABLE laptop
ADD COLUMN touchscreen INT AFTER resolution_height;

SELECT ScreenResolution LIKE '%touch%' FROM laptop;

UPDATE laptop
SET touchscreen = ScreenResolution LIKE '%touch%';

ALTER TABLE laptop
ADD COLUMN ips_panel INT AFTER touchscreen;

SELECT ScreenResolution LIKE '%ips%' FROM laptop;

UPDATE laptop
SET ips_panel = ScreenResolution LIKE '%ips%';

ALTER TABLE laptop
DROP ScreenResolution;

-- ADD NEW COLUMNS TO SPLIT MEMORY COLUMN
ALTER TABLE laptop
ADD COLUMN memory_type VARCHAR(50) AFTER MEMORY,
ADD COLUMN primary_storage INT AFTER memory_type,
ADD COLUMN secondary_storage INT AFTER primary_storage;

SELECT memory,
CASE
	WHEN memory LIKE '%SSD%' AND memory LIKE'%HDD%' THEN 'Hybrid'
    WHEN memory LIKE '%SSD%' THEN 'SSD'
    WHEN memory LIKE '%HDD%' THEN 'HDD'
    WHEN memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN memory LIKE '%Flash Storage%' AND memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END AS 'memory_type'
FROM laptop;

UPDATE laptop
SET memory_type = CASE
	WHEN memory LIKE '%SSD%' AND memory LIKE'%HDD%' THEN 'Hybrid'
    WHEN memory LIKE '%SSD%' THEN 'SSD'
    WHEN memory LIKE '%HDD%' THEN 'HDD'
    WHEN memory LIKE '%Flash Storage%' THEN 'Flash Storage'
    WHEN memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN memory LIKE '%Flash Storage%' AND memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

select Memory,
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
CASE WHEN memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(TRIM(Memory),'+',-1),'[0-9]+') ELSE 0 END
from laptop;

UPDATE laptop
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(TRIM(Memory),'+',-1),'[0-9]+') ELSE 0 END;

SELECT primary_storage,
CASE WHEN primary_storage <= 2 THEN primary_storage * 1024 ELSE primary_storage END,
secondary_storage,
CASE WHEN secondary_storage <= 2 THEN secondary_storage * 1024 ELSE secondary_storage END
FROM laptop;

UPDATE laptop
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage * 1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage * 1024 ELSE secondary_storage END;

ALTER TABLE laptop
DROP COLUMN memory;

ALTER TABLE laptop
DROP COLUMN gpu_name;

-- STARTING WITH EDA ANALYSIS
-- HEAD OF THE DATA
SELECT *
FROM laptop
ORDER BY `phone_id` 
LIMIT 5;

-- TAIL OF THE DATA
SELECT *
FROM laptop
ORDER BY `phone_id` DESC
LIMIT 5;

-- SAMPLE OF THE DATA
SELECT *
FROM laptop
ORDER BY rand()
LIMIT 5;

-- UNIVARIATE ANALYSIS ON NUMERICAL COLUMN(DOING ANALYSIS ON INDIVIDUAL COLUMN)
SELECT 
    COUNT(price) OVER() AS total_count,
    MIN(price) OVER() AS min_price,
    MAX(price) OVER() AS max_price,
    AVG(price) OVER() AS avg_price,
    STD(price) OVER() AS std_deviation,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) OVER() AS Q1,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER() AS Median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) OVER() AS Q3
FROM laptop
ORDER BY `phone_id` 
LIMIT 1;

-- CHECK FOR NULL VALUES
SELECT COUNT(price)
FROM laptop
WHERE price IS NULL;

-- CHECK FOR OUTLIERS
SELECT * FROM (SELECT *,
ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) OVER()) AS Q1,
ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) OVER()) AS Q3
FROM laptop) t
WHERE t.price < t.Q1 - (1.5*(t.Q3-t.Q1)) OR t.price > t.Q1 + (1.5*(t.Q3-t.Q1));

-- CREATE HISTOGRAM
SELECT t.buckets, REPEAT('*',COUNT(*)/10) FROM (SELECT price,
CASE 
	WHEN price BETWEEN 0 AND 25000 THEN  '0-25K'
	WHEN price BETWEEN 25001 AND 50000 THEN  '25K-50k'
	WHEN price BETWEEN 50001 AND 75000 THEN  '50k-75K'
	WHEN price BETWEEN 75001 AND 100000 THEN  '75k-100K'
	WHEN price > 100000 THEN '>100K'
	END AS 'buckets'
FROM laptop) t
GROUP BY t.buckets;

-- UNIVARIATE ANALYSIS ON CATEGORICAL COLUMN(DOING ANALYSIS ON INDIVIDUAL COLUMN)
SELECT company, COUNT(company) 
FROM laptop
GROUP BY company;

-- CHECK FOR NULL VALUES
SELECT COUNT(company)
FROM laptop
WHERE company IS NULL;

-- BIVARIATE ANALYSIS ON NUMERICAL - NUMERICAL COLUMNS(DOING ANALYSIS ON TWO COLUMNS)
SELECT 
    MIN(resolution_width) OVER() AS min_resolution_width,
	MIN(resolution_height) OVER() AS min_resolution_height,
    MAX(resolution_width) OVER() AS max_resolution_width,
	MAX(resolution_height) OVER() AS max_resolution_height,
    AVG(resolution_width) OVER() AS avg_resolution_width,
    AVG(resolution_height) OVER() AS avg_resolution_height,
    STD(resolution_width) OVER() AS std_deviation_resolution_width,
    STD(resolution_height) OVER() AS std_deviation_resolution_height,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY resolution_width) OVER() AS Q1_resolution_width,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY resolution_height) OVER() AS Q1_resolution_height,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_width) OVER() AS Median_resolution_width,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_height) OVER() AS Median_resolution_height,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY resolution_width) OVER() AS Q3_resolution_width,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY resolution_height) OVER() AS Q3_resolution_height
FROM laptop
ORDER BY `phone_id` 
LIMIT 1;

-- CHECK FOR SCREENTOUCH LAPTOPS
SELECT company,
SUM(CASE WHEN  touchscreen = 1 THEN 1 ELSE 0 END) AS 'touchscreen_yes',
SUM(CASE WHEN  touchscreen = 0 THEN 1 ELSE 0 END) AS 'touchscreen_no'
FROM laptop
GROUP BY company;

-- BIVARIATE ANALYSIS ON NUMERICAL - CATEGORICAL COLUMNS(DOING ANALYSIS ON TWO COLUMNS)
SELECT company, MIN(price), MAX(price), AVG(price), STD(price)
FROM laptop
GROUP BY company;

-- DELETE 10 RANDOM VALUES 
UPDATE laptop
SET price = NULL
WHERE phone_id IN (19,56,123,258,365,459,589,678,784,812,952,1059);

-- DEALING WITH MISSING VALUES
-- METHOD 1 FILL WITH AVERAGE PRICE
UPDATE laptop
SET price = (SELECT AVG(price) FROM laptop)
WHERE price IS NULL;

-- METHOD 2 FILL WITH AVEARGE PRICE OF INDIVIDUAL BRAND
UPDATE laptop l1
SET price = (SELECT AVG(price) FROM laptop l2 WHERE l2.company = l1.company)
WHERE price IS NULL;

-- METHOD 3 WITH AVEARGE PRICE OF INDIVIDUAL BRAND AND CPU
UPDATE laptop l1
SET price = (SELECT AVG(price) FROM laptop l2 
WHERE l2.company = l1.company AND l2.cpu_brand = l1.cpu_brand)
WHERE price IS NULL;

-- ADD NEW COLUMN
ALTER TABLE laptop
ADD COLUMN ppi INT AFTER resolution_height;

-- FEATURE ENGINEERING ADDING PPI COLUMN
SELECT ROUND(SQRT(resolution_width*resolution_width +resolution_height*resolution_height) / Inches)
FROM laptop;

-- UPDATE DATA TO NEW PPI COLUMN
UPDATE laptop
SET ppi = ROUND(SQRT(resolution_width*resolution_width +resolution_height*resolution_height) / Inches);

-- ADD NEW COLUMN
ALTER TABLE laptop
ADD COLUMN screen_size VARCHAR(50) AFTER Inches;

-- FEATURE ENGINEERING SCREEN SIZE  COLUMN
SELECT *,
CASE
	WHEN Inches < 14 THEN 'small'
	WHEN Inches >= 14 AND Inches <= 17 THEN 'medium'
    ELSE 'large'
 END AS type
FROM laptop;

-- UPDATE DATA TO NEW SCREEN SIZE COLUMN
UPDATE laptop 
SET screen_size = CASE
	WHEN Inches < 14 THEN 'small'
	WHEN Inches >= 14 AND Inches <= 17 THEN 'medium'
    ELSE 'large'
 END;
 
 -- ONE HOT ENCODING
 SELECT gpu_brand,
	CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'Intel',
	CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'AMD',
	CASE WHEN gpu_brand = 'NVIDIA' THEN 1 ELSE 0 END AS 'NVIDIA',
	CASE WHEN gpu_brand = 'ARM' THEN 1 ELSE 0 END AS 'ARM'
 FROM laptop;
 
 
