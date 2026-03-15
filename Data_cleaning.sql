-- DATA CLEANING

SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- 2. Standardize the data
-- 3. Null/Blank Values
-- 4. Remove any Columns or Rows

-- CREATING A COPY OF RAW DATASET
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- CREATING ROW_NUMBER BY PARTITION
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- CREATING CTE('row_num' IS A CREATED COLUMN WE CANT SELECT IT FROM) THAT WHY WE DONE CTE AND SELECT THE ROW_NUM IN IT ONLY
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- DUPLICATE VALUES COMPANY JUST CHECKING
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- FOR DELETING THE ROWS ISN'T EASY BCZ IN THESE THERE ARE 3 ROWS 2 ARE DUPLICATES AND ONE IS UNIQUE
-- WE CREATE A TABLE WITH ONLY THESE DUPLICATES AND DELETE IN IT
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- ADDS THE COULMNS IN A TABLE LAYOFFS_STAGING2
SELECT *
FROM layoffs_staging2;
-- INSERT ALL THE PARTITION VALUES IN THE TABLE
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
-- DELETE THE DUPLICATES ROWS WHERE ROW_NUM IS > 1
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- 2. Standardize the data
-- UPDATE THE COMPANY
SELECT *
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- UPDATE THE INDUSTRY
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry; -- OR WE CAN ORDER BY 1 BCZ ONLY ONE COLUMN
 
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- IN THIS THE CHANGING THE TEXT CRYPTOCURRENCY TO JUST CRYPTO
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; -- DONE

-- DO FOR THE ALL THE COLUMNS
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1; -- IT LOOK OK WE SKIP IT

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- TRAILING i.e removes specified characters WE GIVEN '.'
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- CHANGING THE DATE FROMTEXT TO DATE FORMAT
SELECT *
FROM layoffs_staging2;

SELECT `date`
FROM layoffs_staging2;

-- (`date`,'%m/%d/%Y') THESE ARE FORMATTING THE DATES WE HAVE TO USE THESE FORMAT ONLY
SELECT `date`,
		STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- CHANGES THE DATE TEXT TO DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

-- FOR CONFORMATION
SELECT `date`
FROM layoffs_staging2;

-- BUT THE DATATYPE WON'T BE CHANGE TO FIX IT
-- DON'T CHANGE IN THE RAW TABLE ONLY  USE IN layoffs_staging2
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3.Null/Blank Values
-- LOOKING THE NULL VALUES IN THE TABLE
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- SEEING THE BLANK VALUES IN THE INDUSTRY COLUMN
SELECT DISTINCT industry
FROM layoffs_staging2;

-- GETTING THE INDUSTRY WITH NULL AND BLANK VALUES
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


-- CHECKING THE COMPANY WHICH HAS THE OTHER VALUES THAN NULL/BLANK 
-- EX: THIS AIRBNB HAS INDUSTRY ONE EMPTY AND ANOTHER IS TRAVEL SO WE NEED TO ADD THE TRAVEL IN THE BLANK
-- CHECK FOR ALL THE COMPANIES WHICH HAVE BLANK/NULL AND MAKE LIKE THIS 
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- SELECTING THE TOTAL WHERE COMPANIES WITH BLANK
-- COMPANIES WITH BLANK ONLY APPEAR BCZ THERE IS WE WANT TO UPADTE THAT BALNK WITH ANOTHER T2
-- EX:IN T1 INDUSTRY HAS A BLANK AND IN T2 BY JOIN THE T2 WITH SAME INDUSTRY WITH TRAVEL WE UPADTE THE BLANK WITH TRAVEL IN THE COMPANY
-- AIRBNB ONE HAS BLANK AND ANOTHER HAS TRAVEL WE KEEP THE TRAVEL INDUSTRY IN BLANK
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- JUST SELECTING T1 AND T2 INDUSTRY FOR A CLEAR VIEW
SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- WE ARE UPDATING THE BLANK VALUES TO NULL VALUES
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- SO WE HAVE NULL VALUES IN THE BLANK SPACES
-- WE UPDATES THE NULL VALUES WITH THE T2 TABLE VALUES
-- EX: TRAVEL ADDED IN THE AIRBNB INDUSTRY BLANK SPACE
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- JUST CHECKING
SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- BUT THE INDUSRTY HAS THE NULL VALUE IN THE ONE COMPANY WHY IT WON'T CHANGE MEANS IN THE T1.INDUSTRY IT IS NULL AND T2.INDUSTRY IS NULL
-- WE CAN'T DONE THESE
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- DELETING THE total_laid_off IS NULL AND percentage_laid_off IS NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- JUST DELETED
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- DELETING THE ROW_NUM COLUMN WE DON'T WANT THAT ANYMORE
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- SELECTING THE FINAL DATA CLENING 
SELECT *
FROM layoffs_staging2;

-- Converting the result to new csv file
SELECT *
FROM layoffs_staging2
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cleaned_layoffs.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';