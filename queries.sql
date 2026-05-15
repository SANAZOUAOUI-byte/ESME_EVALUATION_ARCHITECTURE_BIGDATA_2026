-- Création et sélection de la base de données et du schéma
CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;

CREATE OR REPLACE SCHEMA raw;
USE SCHEMA raw;


-- Création d’un stage connecté au bucket S3
CREATE OR REPLACE STAGE linkedin_stage
URL='s3://snowflake-lab-bucket/';


-- Définition des formats de fichiers CSV et JSON
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY='"'
SKIP_HEADER = 1
NULL_IF=('NULL','null','');

CREATE OR REPLACE FILE FORMAT json_format
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE;


-- Création des tables principales pour stocker les données LinkedIn
CREATE OR REPLACE TABLE job_postings (...);

CREATE OR REPLACE TABLE benefits (...);

CREATE OR REPLACE TABLE employee_counts (...);

CREATE OR REPLACE TABLE job_skills (...);

CREATE OR REPLACE TABLE companies (...);

CREATE OR REPLACE TABLE job_industries (...);

CREATE OR REPLACE TABLE company_industries (...);

CREATE OR REPLACE TABLE company_specialities (...);


-- Chargement des fichiers CSV dans les tables correspondantes
COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE';

COPY INTO benefits
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE';

COPY INTO employee_counts
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE';

COPY INTO job_skills
FROM @linkedin_stage/job_skills.csv
FILE_FORMAT = csv_format
ON_ERROR = 'CONTINUE';


-- Chargement des données JSON dans des tables RAW temporaires
CREATE OR REPLACE TABLE companies_raw (data VARIANT);

COPY INTO companies_raw
FROM @linkedin_stage/companies.json
FILE_FORMAT = json_format
FORCE = TRUE;


-- Extraction des données JSON et insertion dans la table finale
INSERT INTO companies
SELECT ...
FROM companies_raw;


-- Même traitement pour les industries des jobs
CREATE OR REPLACE TABLE job_industries_raw (data VARIANT);

COPY INTO job_industries_raw
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = json_format
FORCE = TRUE;

INSERT INTO job_industries
SELECT ...
FROM job_industries_raw;


-- Même traitement pour les industries des entreprises
CREATE OR REPLACE TABLE company_industries_raw (data VARIANT);

COPY INTO company_industries_raw
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = json_format
FORCE = TRUE;

INSERT INTO company_industries
SELECT ...
FROM company_industries_raw;


-- Même traitement pour les spécialités des entreprises
CREATE OR REPLACE TABLE company_specialities_raw (data VARIANT);

COPY INTO company_specialities_raw
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = json_format
FORCE = TRUE;

INSERT INTO company_specialities
SELECT ...
FROM company_specialities_raw;


-- Analyse des industries les plus présentes
SELECT DISTINCT industry_id, COUNT(*) as nb
FROM job_industries
GROUP BY industry_id
ORDER BY nb DESC;


-- Création d’une table de correspondance entre ID et nom d’industrie
CREATE OR REPLACE TABLE industry_labels AS
SELECT * FROM VALUES (...);


-- Jointure entre les offres d’emploi et les entreprises
SELECT jp.company_name, c.name, c.company_size
FROM job_postings jp
JOIN companies c 
ON SPLIT_PART(jp.company_name, '.', 1) = c.company_id
LIMIT 5;
