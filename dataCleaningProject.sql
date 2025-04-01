-- 🔹 Data Cleaning Project: Layoffs Dataset

-- Step 1: Creating a Working Table Without Duplicates
CREATE TABLE layoff_stage AS 
SELECT *, 
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, 
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs;

-- Step 2: Identifying Duplicates
SELECT * FROM layoff_stage WHERE row_num > 1;

-- Step 3: Removing Duplicates
DELETE FROM layoff_stage WHERE row_num > 1;

-- Drop row_num as it's no longer needed
ALTER TABLE layoff_stage DROP COLUMN row_num;

-- Step 4: Standardizing Data Formatting
UPDATE layoff_stage SET company = TRIM(company);
UPDATE layoff_stage SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
UPDATE layoff_stage SET country = 'United States' WHERE country LIKE 'United States%';

-- Step 5: Converting Date Format
ALTER TABLE layoff_stage MODIFY COLUMN `date` DATE;  -- Ensure column type is DATE
UPDATE layoff_stage SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Step 6: Handling Missing Values
UPDATE layoff_stage 
SET industry = NULL
WHERE industry = '';

-- Filling missing industry data using same company's existing values
UPDATE layoff_stage t1
JOIN layoff_stage t2 
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

-- Step 7: Removing Rows with Irrelevant Data (both layoffs and percentage missing)
DELETE FROM layoff_stage 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Final Check: View Cleaned Data
SELECT * FROM layoff_stage;
