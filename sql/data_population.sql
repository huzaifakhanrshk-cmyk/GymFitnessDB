-- =============================================================
-- GymFitnessDB - DATA POPULATION SCRIPT (Milestone 5)
-- Author: Ali Hassan & Muhammad Huzaifa
-- Description: Load CSV data + DML operations + validation
-- =============================================================

USE GymFitnessDB;

-- =============================================================
-- OPTION A: LOAD DATA FROM CSV FILES
-- Run this if you have the CSV files in the correct folder.
-- Adjust the path to where your CSV files are stored.
-- =============================================================

-- Disable FK checks during bulk load
SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE '/var/lib/mysql-files/members.csv'
INTO TABLE Members
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(member_id, full_name, gender, phone, email, membership_type, join_date);

LOAD DATA INFILE '/var/lib/mysql-files/trainers.csv'
INTO TABLE Trainers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(trainer_id, trainer_name, specialization, phone);

LOAD DATA INFILE '/var/lib/mysql-files/workout_plans.csv'
INTO TABLE Workout_Plans
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(plan_id, member_id, trainer_id, goal, duration_weeks);

LOAD DATA INFILE '/var/lib/mysql-files/attendance.csv'
INTO TABLE Attendance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(attendance_id, member_id, attendance_date, check_in_time, status);

LOAD DATA INFILE '/var/lib/mysql-files/payments.csv'
INTO TABLE Payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, member_id, amount, payment_date, payment_status);

-- Re-enable FK checks
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================
-- OPTION B: SAMPLE INSERT STATEMENTS (first 5 rows each)
-- Use this if LOAD DATA INFILE is not available on your system.
-- =============================================================

-- Sample Members
INSERT INTO Members (full_name, gender, phone, email, membership_type, join_date) VALUES
('Ahmed Raza',    'Male',   '03011234567', 'ahmed.raza@email.com',    'Monthly',   '2024-01-15'),
('Sara Khan',     'Female', '03112345678', 'sara.khan@email.com',     'Annual',    '2024-02-20'),
('Bilal Hussain', 'Male',   '03213456789', 'bilal.h@email.com',       'Quarterly', '2024-03-10'),
('Aisha Siddiqui','Female', '03314567890', 'aisha.s@email.com',       'Monthly',   '2024-04-05'),
('Usman Ali',     'Male',   '03415678901', 'usman.ali@email.com',     'Weekly',    '2024-05-22');

-- Sample Trainers
INSERT INTO Trainers (trainer_name, specialization, phone) VALUES
('Coach Tariq',   'Weight Training', '03521234567'),
('Coach Nadia',   'Yoga',            '03622345678'),
('Coach Farhan',  'Cardio',          '03723456789'),
('Coach Sana',    'CrossFit',        '03824567890'),
('Coach Imran',   'Boxing',          '03925678901');

-- Sample Workout Plans
INSERT INTO Workout_Plans (member_id, trainer_id, goal, duration_weeks) VALUES
(1, 1, 'Muscle Gain',      12),
(2, 2, 'Flexibility',       8),
(3, 3, 'Weight Loss',      16),
(4, 4, 'General Fitness',  10),
(5, 5, 'Endurance',        12);

-- Sample Attendance
INSERT INTO Attendance (member_id, attendance_date, check_in_time, status) VALUES
(1, '2025-01-10', '07:30:00', 'Present'),
(2, '2025-01-10', '08:00:00', 'Present'),
(3, '2025-01-10', '09:15:00', 'Absent'),
(4, '2025-01-11', '07:45:00', 'Present'),
(5, '2025-01-11', '10:00:00', 'Present');

-- Sample Payments
INSERT INTO Payments (member_id, amount, payment_date, payment_status) VALUES
(1, 3500.00, '2025-01-01', 'Paid'),
(2, 30000.00,'2025-01-05', 'Paid'),
(3, 9200.00, '2025-01-10', 'Pending'),
(4, 3400.00, '2025-01-15', 'Paid'),
(5, 1000.00, '2025-01-20', 'Paid');


-- =============================================================
-- DML OPERATIONS — UPDATE & DELETE (Required by Milestone 5)
-- =============================================================

-- UPDATE: Change membership type for member with ID 3
UPDATE Members
SET membership_type = 'Annual'
WHERE member_id = 3;

-- UPDATE: Mark a pending payment as paid
UPDATE Payments
SET payment_status = 'Paid'
WHERE payment_id = 3 AND payment_status = 'Pending';

-- DELETE: Remove attendance record for absent entries older than 2 years
DELETE FROM Attendance
WHERE status = 'Absent'
  AND attendance_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

-- DELETE: Remove a specific workout plan that was cancelled
DELETE FROM Workout_Plans
WHERE plan_id = 5;
