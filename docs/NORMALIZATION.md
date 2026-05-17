# NORMALIZATION.md — GymFitnessDB
**Project:** Gym & Fitness Tracker System  
**Authors:** Ali Hassan & Muhammad Huzaifa  
**Milestone:** 2 — ERD Design & Normalization

---

## Overview

This document walks through the normalization of every table in the GymFitnessDB schema, from First Normal Form (1NF) through Third Normal Form (3NF). For each table and each normal form, we state:
- What the issue was (if any)
- What change was made
- Why the change was necessary

---

## Table 1: Members

### 1NF — First Normal Form
**Rule:** Every column must hold atomic (indivisible) values. No repeating groups.

**Review:**  
The Members table stores one value per cell — `full_name`, `gender`, `phone`, `email`, `membership_type`, and `join_date` are all single-valued. There are no comma-separated lists or arrays stored in any column.

**Verdict:** ✅ Already in 1NF. No changes needed.  
**Justification:** Each attribute contains exactly one value per row. `full_name` stores the complete name as a single string (not split into first/last), which is a deliberate design choice for this system's simplicity. The primary key `member_id` uniquely identifies each row.

---

### 2NF — Second Normal Form
**Rule:** Must be in 1NF, and every non-key attribute must depend on the *whole* primary key (no partial dependencies). Partial dependencies only occur with composite primary keys.

**Review:**  
The Members table has a single-column primary key (`member_id`), so partial dependency is not possible. Every column — `full_name`, `gender`, `phone`, `email`, `membership_type`, `join_date` — fully depends on `member_id`.

**Verdict:** ✅ Already in 2NF. No changes needed.  
**Justification:** With a single-attribute primary key, partial dependency cannot exist by definition. All attributes describe the member directly.

---

### 3NF — Third Normal Form
**Rule:** Must be in 2NF, and no non-key attribute should depend on another non-key attribute (no transitive dependencies).

**Review:**  
We checked whether `membership_type` causes a transitive dependency — for example, if the membership fee or description were stored here, those would depend on `membership_type` rather than directly on `member_id`. Currently, `membership_type` is stored as a simple label (e.g., "Monthly", "Annual") and no other column in the Members table depends on it.

**Verdict:** ✅ Already in 3NF. No changes needed.  
**Justification:** No non-key column depends on another non-key column. Each column describes a direct property of the member identified by `member_id`.

---

## Table 2: Trainers

### 1NF
**Review:**  
All columns (`trainer_name`, `specialization`, `phone`) are atomic and single-valued. No repeating groups exist.

**Verdict:** ✅ Already in 1NF. No changes needed.  
**Justification:** Each trainer row has one name, one specialization, and one phone number.

---

### 2NF
**Review:**  
Single-column primary key (`trainer_id`) means no partial dependency is possible.

**Verdict:** ✅ Already in 2NF. No changes needed.

---

### 3NF
**Review:**  
`specialization` and `phone` both directly describe the trainer. Neither depends on the other. No transitive dependency exists.

**Verdict:** ✅ Already in 3NF. No changes needed.  
**Justification:** All attributes are direct facts about the trainer entity.

---

## Table 3: Workout_Plans

### 1NF
**Review:**  
Original schema had a `goal` field that could potentially hold multiple goals (e.g., "Weight Loss, Muscle Gain"). We enforced a single value per row.

**Issue Found:** The `goal` column was vague and could have been misused to store multiple comma-separated goals.  
**Change Made:** Constrained `goal` to a single descriptive value (VARCHAR(100)) and documented that each plan row represents one goal. If multiple goals are needed in the future, a separate `Plan_Goals` table should be created.  
**Why:** 1NF requires atomic values. A field storing "Weight Loss, Muscle Gain" would violate atomicity.

**Verdict:** ✅ In 1NF after clarification.

---

### 2NF
**Review:**  
Primary key is `plan_id` (single column). `member_id` and `trainer_id` are foreign keys; `goal` and `duration_weeks` describe the plan itself, not parts of a composite key.

**Verdict:** ✅ Already in 2NF. No changes needed.

---

### 3NF
**Review:**  
We checked: does `goal` depend on `trainer_id` rather than on `plan_id`? No — a trainer may set different goals for different plans. `duration_weeks` also depends directly on the plan, not on who the trainer is.

**Verdict:** ✅ Already in 3NF. No changes needed.  
**Justification:** `goal` and `duration_weeks` are properties of the specific workout plan, not of the trainer or member alone.

---

## Table 4: Attendance

### 1NF
**Review:**  
Original schema had only `check_in_time` but no `status` column. We added a `status` ENUM column (`Present`/`Absent`) to make records complete and atomic.

**Issue Found:** Without a `status` column, the presence of a row was used to imply attendance, which is an implicit encoding rather than an explicit atomic value.  
**Change Made:** Added `status ENUM('Present', 'Absent') NOT NULL DEFAULT 'Present'`.  
**Why:** Each row should explicitly and atomically state attendance status rather than relying on implicit logic.

**Verdict:** ✅ In 1NF after adding explicit `status` column.

---

### 2NF
**Review:**  
Single-column primary key (`attendance_id`). All columns directly depend on it.

**Verdict:** ✅ Already in 2NF. No changes needed.

---

### 3NF
**Review:**  
Does `check_in_time` depend on `attendance_date` rather than on `attendance_id`? No — two members could check in on the same date at different times. Each `attendance_id` record independently determines its own date and time.

**Verdict:** ✅ Already in 3NF. No changes needed.

---

## Table 5: Payments

### 1NF
**Review:**  
All columns (`member_id`, `amount`, `payment_date`, `payment_status`) are atomic and single-valued.

**Verdict:** ✅ Already in 1NF. No changes needed.

---

### 2NF
**Review:**  
Single-column primary key (`payment_id`). No partial dependencies possible.

**Verdict:** ✅ Already in 2NF. No changes needed.

---

### 3NF
**Review:**  
Does `payment_status` depend on `amount`? No. Does `amount` depend on `payment_date`? No. All non-key attributes depend only on `payment_id`.

We also considered whether `amount` could transitively depend on `membership_type` via the member. Since membership type is stored in the Members table (not here), and payment amounts can vary freely, no transitive dependency exists.

**Verdict:** ✅ Already in 3NF. No changes needed.  
**Justification:** Each column describes a direct property of the specific payment transaction.

---

## Table 6: Admin (Added in Milestone 4)

### 1NF
All columns atomic. ✅

### 2NF
Single-column PK. ✅

### 3NF
`password` depends directly on `admin_id`. `username` is a unique identifier. No transitive dependencies. ✅

---

## Step 2 — Duplicate & Redundancy Check

| Check | Finding | Action |
|---|---|---|
| `phone` in both Members and Trainers | Different entities, no redundancy | No change needed |
| `member_id` appears in Workout_Plans, Attendance, Payments | These are foreign keys, not redundancy | No change needed |
| `trainer_id` appears in Workout_Plans | Foreign key, correct | No change needed |
| `goal` in Workout_Plans | Single value, atomic | No change needed |
| `status` in Attendance and Payments | Different tables, different contexts | No change needed |

**Conclusion:** No redundant columns or overlapping attributes were found across tables. Each table has a clear, distinct responsibility.

---

## Step 3 — Updated ERD Summary

After normalization, the final schema is:

```
Members(member_id PK, full_name, gender, phone, email, membership_type, join_date)
Trainers(trainer_id PK, trainer_name, specialization, phone)
Workout_Plans(plan_id PK, member_id FK, trainer_id FK, goal, duration_weeks)
Attendance(attendance_id PK, member_id FK, attendance_date, check_in_time, status)
Payments(payment_id PK, member_id FK, amount, payment_date, payment_status)
Admin(admin_id PK, username, password)
```

**Relationships:**
- Members → Workout_Plans: 1:N (one member can have many plans)
- Trainers → Workout_Plans: 1:N (one trainer can manage many plans)
- Members → Attendance: 1:N (one member has many attendance records)
- Members → Payments: 1:N (one member can make many payments)

All primary keys, foreign keys, relationships, and cardinalities are reflected in the ERD diagram (`docs/ERD.png`).

---

## Commit Message for This Milestone

```
M2: Applied 1NF-3NF normalization, added status column to Attendance, updated ERD and schema
```
