-- ============================================================
-- Business Question 1:
-- Berapa attrition rate keseluruhan dan bagaimana breakdown-nya
-- per departemen, job role, dan job level?
-- ============================================================
USE hr_attrition_analysis;

-- ------------------------------------------------------------
-- 1a. Attrition rate keseluruhan (baseline)
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_employees,
    SUM(
        CASE
            WHEN attrition = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_left,
    ROUND(
        (
            SUM(
                CASE
                    WHEN attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) * 100
        ) / COUNT(*),
        2
    ) AS attrition_rate_pct
FROM employees;

-- ------------------------------------------------------------
-- 1b. Attrition rate per departemen, di-rank dari yang tertinggi
-- Departemen mana yang paling beresiko?
-- ------------------------------------------------------------
WITH
    department_attrition AS (
        SELECT
            d.department_name,
            COUNT(*) AS total_employees,
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) AS total_left,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN e.attrition = 'Yes' THEN 1
                            ELSE 0
                        END
                    ) * 100
                ) / COUNT(*),
                2
            ) AS attrition_rate_pct
        FROM employees e
            JOIN departments d ON e.department_id = d.department_id
        GROUP BY
            d.department_name
    )
SELECT
    department_name,
    total_employees,
    total_left,
    attrition_rate_pct,
    RANK() OVER (
        ORDER BY attrition_rate_pct DESC
    ) AS risk_rank
FROM department_attrition
ORDER BY risk_rank;

-- -------------------------------------------------------------
-- 1c. Attrition rate per job role
-- Job role apa yang perlu diperhatikan?
-- -------------------------------------------------------------
WITH
    role_attrition AS (
        SELECT
            jr.job_role_name,
            COUNT(*) AS total_employees,
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) AS total_left,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN e.attrition = 'Yes' THEN 1
                            ELSE 0
                        END
                    ) * 100
                ) / COUNT(*),
                2
            ) AS attrition_rate_pct
        FROM employees e
            JOIN job_roles jr ON e.job_role_id = jr.job_role_id
        GROUP BY
            jr.job_role_name
    )
SELECT
    job_role_name,
    total_employees,
    total_left,
    attrition_rate_pct,
    NTILE(4) OVER (
        ORDER BY attrition_rate_pct DESC
    ) AS risk_quartile
FROM role_attrition
ORDER BY attrition_rate_pct DESC;

-- -------------------------------------------------------------
-- 1d. Attrition rate per job level
-- Apakah risiko attrition menurun atau malah meningkat seiring
-- naik level jabatan?
-- -------------------------------------------------------------
WITH
    level_attrition AS (
        SELECT
            job_level,
            COUNT(*) AS total_employees,
            SUM(
                CASE
                    WHEN attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) AS total_left,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN attrition = 'Yes' THEN 1
                            ELSE 0
                        END
                    ) * 100
                ) / COUNT(*),
                2
            ) AS attrition_rate_pct
        FROM employees
        GROUP BY
            job_level
    )
SELECT
    job_level,
    total_employees,
    total_left,
    attrition_rate_pct,
    attrition_rate_pct - LAG(attrition_rate_pct, 1) OVER (
        ORDER BY job_level ASC
    ) AS difference_level_rate
FROM level_attrition
ORDER BY job_level;

-- -------------------------------------------------------------
-- 1e. Kombinasi departemen x job level, dengan kolom kontribusi
-- persentase terhadap total karyawan yang keluar perusahaan
-- -------------------------------------------------------------
WITH
    department_level_attrition AS (
        SELECT
            d.department_name,
            e.job_level,
            COUNT(*) AS total_employees,
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) AS total_left,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN e.attrition = 'Yes' THEN 1
                            ELSE 0
                        END
                    ) * 100
                ) / COUNT(*),
                2
            ) AS attrition_rate_pct
        FROM employees e
            JOIN departments d ON e.department_id = d.department_id
        GROUP BY
            d.department_name,
            e.job_level
        HAVING
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) > 0
    )
SELECT
    department_name,
    job_level,
    total_employees,
    total_left,
    attrition_rate_pct,
    ROUND(
        (total_left * 100) / SUM(total_left) OVER (),
        2
    ) AS pct_contribution_to_total_leaves
FROM department_level_attrition
ORDER BY
    pct_contribution_to_total_leaves DESC;

-- -------------------------------------------------------------
-- 1f. Kombinasi job role x job level, dengan kolom kontribusi
-- persentase terhadap total karyawan yang keluar perusahaan
-- -------------------------------------------------------------
WITH
    role_level_attrition AS (
        SELECT
            jr.job_role_name,
            e.job_level,
            COUNT(*) AS total_employees,
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) AS total_left,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN e.attrition = 'Yes' THEN 1
                            ELSE 0
                        END
                    ) * 100
                ) / COUNT(*),
                2
            ) AS attrition_rate_pct
        FROM employees e
            JOIN job_roles jr ON e.job_role_id = jr.job_role_id
        GROUP BY
            jr.job_role_name,
            e.job_level
        HAVING
            SUM(
                CASE
                    WHEN e.attrition = 'Yes' THEN 1
                    ELSE 0
                END
            ) > 0
    )
SELECT
    job_role_name,
    job_level,
    total_employees,
    total_left,
    attrition_rate_pct,
    ROUND(
        (total_left * 100) / SUM(total_left) OVER (),
        2
    ) AS pct_contribution_to_total_leaves
FROM role_level_attrition
ORDER BY
    pct_contribution_to_total_leaves DESC;