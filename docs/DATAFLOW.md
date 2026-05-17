# DATAFLOW.md — GymFitnessDB
**Project:** Gym & Fitness Tracker System  
**Authors:** Ali Hassan & Muhammad Huzaifa  
**Milestone:** 3 — Dataset Preprocessing & Dataflow

---

## System Overview

The Gym & Fitness Tracker is a Flask-based web application backed by a MySQL database (GymFitnessDB). It is used by gym administrators to manage members, assign trainers, record attendance, track workout plans, and process payments — all through a browser-based dashboard.

---

## Where Data Enters the System

Data enters the GymFitnessDB system through three distinct pathways:

### 1. Admin Web Interface (Primary Entry Point)
The Flask application at `app.py` provides HTML forms that gym staff use to input data in real time:
- **Members page (`/`):** Staff enter a member's name, age, gender, and phone number to register a new member.
- **Attendance marking (`/mark_attendance/<id>`):** A single click records a Present entry for the selected member with today's date and current time.
- **Payment recording (`/pay/<id>`):** Staff enter a payment amount, which is saved with the current date and a "Paid" status.

### 2. Bulk CSV Import (Milestone 3 — Synthetic Data Load)
For initial population and testing, structured CSV files are loaded using MySQL's `LOAD DATA INFILE` or Python `INSERT` scripts. One CSV file corresponds to each table:
- `csv/members.csv`
- `csv/trainers.csv`
- `csv/workout_plans.csv`
- `csv/attendance.csv`
- `csv/payments.csv`

### 3. Direct SQL Scripts (Development & Setup)
Database administrators run `sql/schema.sql` to create all tables, and `sql/data_population.sql` to load seed data. Validation queries in `sql/validation.sql` are run after loading to confirm integrity.

---

## How Data Moves Through the Database

The data flow follows the dependency order of the schema:

```
[Admin Login]
      |
      v
[Admin Table] ──────────────────────────────────────────────────
      |
      v (authenticated session)
[Members Table] ←── staff registers new members
      |
      |─────────────────────────┐──────────────────┐
      v                         v                  v
[Workout_Plans Table]    [Attendance Table]   [Payments Table]
      |                                            
      v                                            
[Trainers Table] ←── Workout_Plans links each member to a trainer
```

### Detailed Flow:

**Step 1 — Admin Authentication**  
The admin logs in via `/login`. Credentials are checked against the `Admin` table. On success, a session is created and the admin is redirected to the dashboard.

**Step 2 — Member Registration**  
A new member is added to the `Members` table. This is the prerequisite step — no other table can reference a member until they exist here.

**Step 3 — Trainer Assignment (via Workout Plans)**  
A workout plan is created in `Workout_Plans`, linking a `member_id` (from Members) and a `trainer_id` (from Trainers). This is a junction between the two parent entities.

**Step 4 — Attendance Recording**  
When a member checks in, a row is inserted into `Attendance` with `member_id`, today's date, the current time, and status = `Present`. The dashboard reads this table to show today's attendance count.

**Step 5 — Payment Recording**  
Payments are inserted into `Payments` with `member_id`, amount, date, and status. The dashboard aggregates `SUM(amount)` from this table for total revenue display.

---

## What Comes Out

| Output | Source | How It's Used |
|---|---|---|
| Dashboard stats | COUNT from Members, SUM from Payments, COUNT from Attendance | Displayed on `/dashboard` |
| Members list | JOIN of Members + Trainers via Workout_Plans | Displayed on `/` (index page) |
| Attendance log | JOIN of Attendance + Members | Displayed on `/attendance` |
| Payment log | JOIN of Payments + Members | Displayed on `/payments` |
| Trainer list | Direct SELECT from Trainers | Displayed on `/trainers` |
| Validation reports | COUNT(*), NULL checks, FK JOIN checks | Used by admin/teacher to verify data integrity |

---

## Data Dependency Order (Load Order for CSV Import)

When populating the database, tables must be loaded in this exact order to respect foreign key constraints:

```
1. Admin          (no dependencies)
2. Members        (no dependencies)
3. Trainers       (no dependencies)
4. Workout_Plans  (depends on Members + Trainers)
5. Attendance     (depends on Members)
6. Payments       (depends on Members)
```

Loading out of order will cause foreign key constraint violations.

---

## Commit Message for This Milestone

```
M3: Synthetic data generated (50-100 rows/table); dataflow documented
```
