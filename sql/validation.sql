-- =============================================================
-- GymFitnessDB - VALIDATION QUERIES (Milestone 5)
-- Author: Ali Hassan & Muhammad Huzaifa
-- Run these after loading data to confirm integrity
-- =============================================================

USE GymFitnessDB;

-- =============================================================
-- SECTION 1: ROW COUNT VALIDATION
-- Confirm all tables are populated
-- =============================================================

SELECT 'Members'      AS table_name, COUNT(*) AS row_count FROM Members
UNION ALL
SELECT 'Trainers'     AS table_name, COUNT(*) AS row_count FROM Trainers
UNION ALL
SELECT 'Workout_Plans'AS table_name, COUNT(*) AS row_count FROM Workout_Plans
UNION ALL
SELECT 'Attendance'   AS table_name, COUNT(*) AS row_count FROM Attendance
UNION ALL
SELECT 'Payments'     AS table_name, COUNT(*) AS row_count FROM Payments;

-- Expected output: 100, 15, 80, 100, 100 (or close after DELETEs)


-- =============================================================
-- SECTION 2: NULL CHECK ON KEY COLUMNS
-- Confirm required fields are never null
-- =============================================================

-- Members: full_name, phone, membership_type must not be null
SELECT 'Members - NULL full_name'       AS check_name, COUNT(*) AS null_count FROM Members WHERE full_name IS NULL
UNION ALL
SELECT 'Members - NULL phone'           AS check_name, COUNT(*) AS null_count FROM Members WHERE phone IS NULL
UNION ALL
SELECT 'Members - NULL membership_type' AS check_name, COUNT(*) AS null_count FROM Members WHERE membership_type IS NULL
UNION ALL
-- Payments: amount, payment_status must not be null
SELECT 'Payments - NULL amount'         AS check_name, COUNT(*) AS null_count FROM Payments WHERE amount IS NULL
UNION ALL
SELECT 'Payments - NULL status'         AS check_name, COUNT(*) AS null_count FROM Payments WHERE payment_status IS NULL
UNION ALL
-- Attendance: attendance_date must not be null
SELECT 'Attendance - NULL date'         AS check_name, COUNT(*) AS null_count FROM Attendance WHERE attendance_date IS NULL;

-- Expected: all null_count values = 0


-- =============================================================
-- SECTION 3: FOREIGN KEY INTEGRITY CHECKS
-- Confirm referential integrity via JOIN
-- =============================================================

-- Check: every Workout_Plan links to a valid Member
SELECT 'Orphan Workout_Plans (no matching member)' AS check_name,
       COUNT(*) AS bad_count
FROM Workout_Plans wp
LEFT JOIN Members m ON wp.member_id = m.member_id
WHERE m.member_id IS NULL;

-- Check: every Workout_Plan links to a valid Trainer
SELECT 'Orphan Workout_Plans (no matching trainer)' AS check_name,
       COUNT(*) AS bad_count
FROM Workout_Plans wp
LEFT JOIN Trainers t ON wp.trainer_id = t.trainer_id
WHERE t.trainer_id IS NULL;

-- Check: every Attendance record links to a valid Member
SELECT 'Orphan Attendance (no matching member)' AS check_name,
       COUNT(*) AS bad_count
FROM Attendance a
LEFT JOIN Members m ON a.member_id = m.member_id
WHERE m.member_id IS NULL;

-- Check: every Payment links to a valid Member
SELECT 'Orphan Payments (no matching member)' AS check_name,
       COUNT(*) AS bad_count
FROM Payments p
LEFT JOIN Members m ON p.member_id = m.member_id
WHERE m.member_id IS NULL;

-- Expected: all bad_count values = 0


-- =============================================================
-- SECTION 4: BUSINESS LOGIC VALIDATION QUERIES
-- =============================================================

-- Total revenue from paid payments
SELECT SUM(amount) AS total_revenue_paid
FROM Payments
WHERE payment_status = 'Paid';

-- Members with most attendance
SELECT m.full_name, COUNT(a.attendance_id) AS sessions
FROM Members m
JOIN Attendance a ON m.member_id = a.member_id
WHERE a.status = 'Present'
GROUP BY m.member_id, m.full_name
ORDER BY sessions DESC
LIMIT 10;

-- Membership type distribution
SELECT membership_type, COUNT(*) AS member_count
FROM Members
GROUP BY membership_type
ORDER BY member_count DESC;

-- Trainer workload (how many plans each trainer manages)
SELECT t.trainer_name, t.specialization, COUNT(wp.plan_id) AS active_plans
FROM Trainers t
LEFT JOIN Workout_Plans wp ON t.trainer_id = wp.trainer_id
GROUP BY t.trainer_id, t.trainer_name, t.specialization
ORDER BY active_plans DESC;

-- Pending payments summary
SELECT m.full_name, p.amount, p.payment_date
FROM Payments p
JOIN Members m ON p.member_id = m.member_id
WHERE p.payment_status = 'Pending'
ORDER BY p.payment_date;
