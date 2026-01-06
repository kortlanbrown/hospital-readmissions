-- Drop tables if they exist (so you can re-run safely)
DROP TABLE IF EXISTS diagnoses;
DROP TABLE IF EXISTS admissions;
DROP TABLE IF EXISTS patients;

-- Patients table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    gender VARCHAR(10),
    age INT
);

-- Admissions table
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    admit_date DATE NOT NULL,
    discharge_date DATE NOT NULL
);

-- Diagnoses table (1 admission can have multiple diagnosis codes)
CREATE TABLE diagnoses (
    diagnosis_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    admission_id INT REFERENCES admissions(admission_id),
    diagnosis_code VARCHAR(10) NOT NULL
);

-- Insert patients
INSERT INTO patients (patient_id, gender, age) VALUES
(1, 'M', 72),
(2, 'F', 68),
(3, 'M', 55),
(4, 'F', 81),
(5, 'M', 63);

-- Insert admissions
INSERT INTO admissions (admission_id, patient_id, admit_date, discharge_date) VALUES
(101, 1, '2025-01-05', '2025-01-10'),
(102, 1, '2025-01-28', '2025-02-02'),  -- within 30 days
(103, 1, '2025-05-15', '2025-05-18'),

(201, 2, '2025-02-01', '2025-02-05'),
(202, 2, '2025-04-01', '2025-04-04'),  -- within 90 days

(301, 3, '2025-03-10', '2025-03-12'),

(401, 4, '2025-01-10', '2025-01-16'),
(402, 4, '2025-01-25', '2025-01-29'),  -- within 30 days
(403, 4, '2025-03-20', '2025-03-25'),  -- within 90 days of 402 discharge

(501, 5, '2025-06-01', '2025-06-05');

-- Insert diagnoses
INSERT INTO diagnoses (admission_id, diagnosis_code) VALUES
(101, 'I50'), (101, 'E11'),
(102, 'I50'),
(103, 'J44'),

(201, 'E11'),
(202, 'E11'),

(301, 'M54'),

(401, 'I50'),
(402, 'I50'),
(403, 'N18'),

(501, 'J44');

SELECT * FROM patients;
SELECT * FROM  admissions;
SELECT * FROM diagnoses;

WITH ranked AS (
    SELECT
        admission_id,
        patient_id,
        admit_date,
        discharge_date,
        LAG(discharge_date) OVER (
            PARTITION BY patient_id
            ORDER BY admit_date
        ) AS prev_discharge
    FROM admissions
)
SELECT
    patient_id,
    admission_id,
    admit_date,
    discharge_date,
    prev_discharge,
    (admit_date - prev_discharge) AS days_since_last_discharge,
    CASE
        WHEN prev_discharge IS NOT NULL AND (admit_date - prev_discharge) <= 30 THEN 1
        ELSE 0
    END AS readmit_30_flag
FROM ranked
ORDER BY patient_id, admit_date;

WITH ranked AS (
    SELECT
        admission_id,
        patient_id,
        admit_date,
        discharge_date,
        LAG(discharge_date) OVER (
            PARTITION BY patient_id
            ORDER BY admit_date
        ) AS prev_discharge
    FROM admissions
)
SELECT
    patient_id,
    admission_id,
    admit_date,
    discharge_date,
    prev_discharge,
    (admit_date - prev_discharge) AS days_since_last_discharge,
    CASE
        WHEN prev_discharge IS NOT NULL AND (admit_date - prev_discharge) <= 90 THEN 1
        ELSE 0
    END AS readmit_90_flag
FROM ranked
ORDER BY patient_id, admit_date;

WITH ranked AS (
    SELECT
        admission_id,
        patient_id,
        admit_date,
        discharge_date,
        LAG(discharge_date) OVER (
            PARTITION BY patient_id
            ORDER BY admit_date
        ) AS prev_discharge
    FROM admissions
),
flags AS (
    SELECT
        admission_id,
        patient_id,
        CASE
            WHEN prev_discharge IS NOT NULL AND (admit_date - prev_discharge) <= 30 THEN 1
            ELSE 0
        END AS readmit_30_flag
    FROM ranked
)
SELECT
    d.diagnosis_code,
    COUNT(*) AS admissions_with_diagnosis,
    SUM(f.readmit_30_flag) AS readmit_30_count,
    ROUND(100.0 * SUM(f.readmit_30_flag) / COUNT(*), 1) AS readmit_30_rate_pct
FROM diagnoses d
JOIN flags f ON d.admission_id = f.admission_id
GROUP BY d.diagnosis_code
ORDER BY readmit_30_rate_pct DESC, admissions_with_diagnosis DESC;

