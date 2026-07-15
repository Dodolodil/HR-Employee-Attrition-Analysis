-- =============================================================
-- HR Employee Attrition Analysis - Schema & Data Load
-- =============================================================
-- Jalankan file ini di MySQL setelah CSV hasil normalisasi
-- (dari notebook 01_data_preparation_HR.ipynb) sudah tersedia.
-- =============================================================

CREATE DATABASE IF NOT EXISTS hr_attrition_analysis;

USE hr_attrition_analysis;

-- -------------------------------------------------------------
-- Drop table jika sudah ada
-- -------------------------------------------------------------
DROP TABLE IF EXISTS satisfaction_scores;

DROP TABLE IF EXISTS compensation;

DROP TABLE IF EXISTS employees;

DROP TABLE IF EXISTS job_roles;

DROP TABLE IF EXISTS education_fields;

DROP TABLE IF EXISTS departments;

-- -------------------------------------------------------------
-- Tabel dimensi
-- -------------------------------------------------------------
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

CREATE Table job_roles (
    job_role_id INT PRIMARY KEY,
    job_role_name VARCHAR(50) NOT NULL
);

CREATE Table education_fields (
    education_field_id INT PRIMARY KEY,
    field_name VARCHAR(50) NOT NULL
);

-- ------------------------------------------------------------
-- Tabel inti - employees
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    age TINYINT UNSIGNED NOT NULL,
    gender ENUM('Male', 'Female') NOT NULL,
    marital_status ENUM(
        'Single',
        'Maried',
        'Divorced'
    ) NOT NULL,
    attrition ENUM('Yes', 'No') NOT NULL,
    business_travel ENUM(
        'Non-Travel',
        'Travel_Rarely',
        'Travel_Frequently'
    ) NOT NULL,
    over_time ENUM('Yes', 'No') NOT NULL,
    distance_from_home SMALLINT NOT NULL,
    education_level TINYINT NOT NULL,
    job_level TINYINT NOT NULL,
    num_companies_worked TINYINT NOT NULL,
    total_working_years TINYINT NOT NULL,
    years_at_company TINYINT NOT NULL,
    years_in_current_role TINYINT NOT NULL,
    years_since_last_promotion TINYINT NOT NULL,
    years_with_curr_manager TINYINT NOT NULL,
    training_times_last_year TINYINT NOT NULL,
    department_id INT NOT NULL,
    job_role_id INT NOT NULL,
    education_field_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    Foreign Key (job_role_id) REFERENCES job_roles (job_role_id),
    Foreign Key (education_field_id) REFERENCES education_fields (education_field_id)
);

-- ------------------------------------------------------------
-- Tabel relasi 1:1 - compensation
-- ------------------------------------------------------------
CREATE TABLE compensation (
    employee_id INT PRIMARY KEY,
    daily_rate INT NOT NULL,
    hourly_rate INT NOT NULL,
    monthly_income INT NOT NULL,
    monthly_rate INT NOT NULL,
    percent_salary_hike TINYINT NOT NULL,
    stock_option_level TINYINT NOT NULL,
    Foreign Key (employee_id) REFERENCES employees (employee_id)
);

-- ------------------------------------------------------------
-- Tabel relasi 1:1 - satisfaction_scores
-- ------------------------------------------------------------
CREATE TABLE satisfaction_scores (
    employee_id INT PRIMARY KEY,
    environment_satisfaction TINYINT NOT NULL,
    job_involvement TINYINT NOT NULL,
    job_satisfaction TINYINT NOT NULL,
    relationship_satisfaction TINYINT NOT NULL,
    work_life_balance TINYINT NOT NULL,
    performance_rating TINYINT NOT NULL,
    Foreign Key (employee_id) REFERENCES employees (employee_id)
);

-- ============================================================
-- LOAD DATA
-- Sesuaikan path folder 'normalized_csv/' dengan lokasi file
-- di komputer. Jika MySQL menolak karena secure-file-priv,
-- pindahkan CSV ke folder yang diizinkan (cara mengecek folder
-- yang diizinkan dengan SHOW VARIABLES LIKE 'secure_file_priv';)
-- ============================================================

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'normalized_csv/departments.csv' INTO
TABLE departments FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'normalized_csv/job_roles.csv' INTO
TABLE job_roles FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'normalized_csv/education_fields.csv' INTO
TABLE education_fields FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'normalized_csv/employees.csv' INTO
TABLE employees FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'normalized_csv/compensation.csv' INTO
TABLE compensation FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'normalized_csv/satisfaction_scores.csv' INTO
TABLE satisfaction_scores FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- -----------------------------------------------------------
-- Sanity check setelah load
-- -----------------------------------------------------------
SELECT
    'departments' AS tabel_departments,
    COUNT(*) AS total_rows
FROM departments
UNION ALL
SELECT 'job_roles', COUNT(*)
FROM job_roles
UNION ALL
SELECT 'education_fields', COUNT(*)
FROM education_fields
UNION ALL
SELECT 'employees', COUNT(*)
FROM employees
UNION ALL
SELECT 'compensation', COUNT(*)
FROM compensation
UNION ALL
SELECT 'satisfaction_scores', COUNT(*)
FROM satisfaction_scores;