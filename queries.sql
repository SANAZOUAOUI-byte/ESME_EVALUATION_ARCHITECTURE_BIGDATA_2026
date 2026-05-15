CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;
CREATE OR REPLACE SCHEMA raw;
USE SCHEMA raw;

CREATE OR REPLACE STAGE linkedin_stage
URL='s3://snowflake-lab-bucket/';

CREATE OR REPLACE FILE FORMAT csv_format
TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY='"'
SKIP_HEADER = 1
NULL_IF=('NULL','null','');

CREATE OR REPLACE FILE FORMAT json_format
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE;

CREATE OR REPLACE TABLE job_postings (
    job_id STRING,
    company_name STRING,
    title STRING,
    description STRING,
    max_salary FLOAT,
    med_salary FLOAT,
    min_salary FLOAT,
    pay_period STRING,
    formatted_work_type STRING,
    location STRING,
    applies STRING,
    original_listed_time STRING,
    remote_allowed STRING,
    views STRING,
    job_posting_url STRING,
    application_url STRING,
    application_type STRING,
    expiry STRING,
    closed_time STRING,
    formatted_experience_level STRING,
    skills_desc STRING,
    listed_time STRING,
    posting_domain STRING,
    sponsored STRING,
    work_type STRING,
    currency STRING,
    compensation_type STRING
);

CREATE OR REPLACE TABLE benefits (
    job_id STRING,
    inferred STRING,
    type STRING
);

CREATE OR REPLACE TABLE employee_counts (
    company_id STRING,
    employee_count STRING,
    follower_count STRING,
    time_recorded STRING
);

CREATE OR REPLACE TABLE job_skills (
    job_id STRING,
    skill_abr STRING
);

CREATE OR REPLACE TABLE companies (
    company_id STRING,
    name STRING,
    description STRING,
    company_size STRING,
    state STRING,
    country STRING,
    city STRING,
    zip_code STRING,
    address STRING,
    url STRING
);

CREATE OR REPLACE TABLE job_industries (
    job_id STRING,
    industry_id STRING
);

CREATE OR REPLACE TABLE company_industries (
    company_id STRING,
    industry STRING
);

CREATE OR REPLACE TABLE company_specialities (
    company_id STRING,
    speciality STRING
);
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

CREATE OR REPLACE TABLE companies_raw (data VARIANT);
COPY INTO companies_raw
FROM @linkedin_stage/companies.json
FILE_FORMAT = json_format
FORCE = TRUE;
INSERT INTO companies
SELECT data:company_id::STRING, data:name::STRING, data:description::STRING,
data:company_size::STRING, data:state::STRING, data:country::STRING,
data:city::STRING, data:zip_code::STRING, data:address::STRING, data:url::STRING
FROM companies_raw;

CREATE OR REPLACE TABLE job_industries_raw (data VARIANT);
COPY INTO job_industries_raw
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = json_format
FORCE = TRUE;
INSERT INTO job_industries
SELECT data:job_id::STRING, data:industry_id::STRING
FROM job_industries_raw;

CREATE OR REPLACE TABLE company_industries_raw (data VARIANT);
COPY INTO company_industries_raw
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = json_format
FORCE = TRUE;
INSERT INTO company_industries
SELECT data:company_id::STRING, data:industry::STRING
FROM company_industries_raw;

CREATE OR REPLACE TABLE company_specialities_raw (data VARIANT);
COPY INTO company_specialities_raw
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = json_format
FORCE = TRUE;
INSERT INTO company_specialities
SELECT data:company_id::STRING, data:speciality::STRING
FROM company_specialities_raw;
SELECT DISTINCT industry_id, COUNT(*) as nb
FROM job_industries
GROUP BY industry_id
ORDER BY nb DESC;
CREATE OR REPLACE TABLE industry_labels AS
SELECT * FROM VALUES
  ('96',  'Technology & IT'),
  ('14',  'Arts & Design'),
  ('4',   'Education'),
  ('27',  'Finance'),
  ('104', 'Staffing & Recruiting'),
  ('43',  'Software & IT'),
  ('1',   'Technology'),
  ('10',  'Retail'),
  ('100', 'Human Resources'),
  ('101', 'Accounting'),
  ('102', 'Insurance'),
  ('103', 'Wellness & Fitness'),
  ('105', 'Medical & Health'),
  ('106', 'Media & Communications'),
  ('107', 'Manufacturing'),
  ('108', 'Legal'),
  ('109', 'Real Estate'),
  ('110', 'Construction'),
  ('3',   'Finance & Banking'),
  ('5',   'Healthcare'),
  ('6',   'Media'),
  ('7',   'Manufacturing'),
  ('8',   'Legal'),
  ('9',   'Real Estate'),
  ('11',  'Construction'),
  ('12',  'Transportation'),
  ('13',  'Energy & Mining'),
  ('15',  'Marketing & Advertising'),
  ('16',  'Consulting'),
  ('17',  'Government'),
  ('18',  'Non-profit'),
  ('19',  'Hospitality'),
  ('20',  'Agriculture'),
  ('21',  'Pharmaceuticals'),
  ('25',  'Biotechnology'),
  ('26',  'Medical Devices'),
  ('28',  'Investment Management'),
  ('29',  'Banking'),
  ('30',  'Insurance'),
  ('31',  'Accounting'),
  ('35',  'Telecommunications'),
  ('37',  'Defense & Space'),
  ('38',  'Mechanical Engineering'),
  ('39',  'Electrical Engineering'),
  ('41',  'Civil Engineering'),
  ('42',  'Architecture'),
  ('44',  'Computer Hardware'),
  ('45',  'Semiconductors'),
  ('46',  'Networking'),
  ('47',  'Cybersecurity'),
  ('48',  'Data & Analytics'),
  ('80',  'Logistics & Supply Chain'),
  ('84',  'Automotive'),
  ('87',  'Airlines & Aviation'),
  ('88',  'Maritime'),
  ('89',  'Railroad Manufacture'),
  ('90',  'Renewables & Environment'),
  ('91',  'Oil & Energy'),
  ('92',  'Mining & Metals'),
  ('93',  'Chemicals'),
  ('94',  'Plastics'),
  ('95',  'Glass & Ceramics'),
  ('97',  'Printing'),
  ('98',  'Packaging & Containers'),
  ('99',  'Textiles'),
  ('2',   'Computer Science')
AS t(industry_id, industry_name);
USE DATABASE linkedin;
USE SCHEMA raw;

SELECT jp.company_name, c.name, c.company_size
FROM job_postings jp
JOIN companies c ON SPLIT_PART(jp.company_name, '.', 1) = c.company_id
LIMIT 5;