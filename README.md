# SQL Layoffs Data Cleaning Project

## Project Overview

This project focuses on cleaning and preparing a global layoffs dataset using SQL.
The raw dataset contained duplicates, inconsistent text values, missing data, and formatting issues.
Using MySQL, the dataset was cleaned and transformed to make it suitable for analysis and reporting.

## Tools & Technologies

* SQL (MySQL)
* Window Functions
* Data Cleaning Techniques
* GitHub

## Dataset

The dataset contains global layoffs data including:

* Company
* Location
* Industry
* Total Laid Off
* Percentage Laid Off
* Date
* Company Stage
* Country
* Funds Raised

The dataset was imported into MySQL for cleaning and transformation.

## Project Structure

```
sql-layoffs-project
│
├── Data_cleaning.sql        # SQL script used for cleaning the dataset
├── layoffs.csv              # Raw dataset
├── cleaned_layoffs.csv      # Final cleaned dataset
└── README.md                # Project documentation
```

## Data Cleaning Process

The following steps were performed to clean the dataset:

### 1. Creating a Staging Table

A staging table was created to avoid modifying the raw dataset.

```
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
```

### 2. Removing Duplicate Records

Duplicates were identified using the **ROW_NUMBER() window function** and removed.

```
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off,
date, stage, country, funds_raised_millions
)
```

### 3. Standardizing Data

Text values were standardized for consistency.

Examples:

* Trimmed extra spaces from company names
* Converted "CryptoCurrency" variations to **Crypto**
* Cleaned country values like **United States. → United States**

```
UPDATE layoffs_staging2
SET company = TRIM(company);
```

### 4. Fixing Date Format

The date column was converted from text format to SQL **DATE** format.

```
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date,'%m/%d/%Y');
```

### 5. Handling Null and Blank Values

Blank industry values were replaced using data from matching companies.

```
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
```

### 6. Removing Invalid Rows

Rows where both `total_laid_off` and `percentage_laid_off` were NULL were removed.

```
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```

### 7. Final Clean Dataset

After cleaning and transformations, the final cleaned dataset was exported as:

```
cleaned_layoffs.csv
```

## Skills Demonstrated

* SQL Data Cleaning
* Window Functions
* Data Standardization
* Handling Missing Values
* Data Transformation
* Database Table Management

## Future Improvements

* Perform exploratory data analysis (EDA)
* Create dashboards using Power BI or Tableau
* Analyze layoffs trends by year, industry, and country

## Author

Prasanna Kumar Reddy
