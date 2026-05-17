# 🏋️ GymFitnessDB — Gym & Fitness Tracker System

**Authors:** Ali Hassan & Muhammad Huzaifa  
**Course:** Database Management (DBMS) — SE Group A  
**Milestone:** 2, 3, 4, 5 ✅

---

## Project Overview

GymFitnessDB is a full-stack web application for managing gym operations. Built with **Python Flask** and **MySQL**, it allows gym administrators to manage members, assign trainers, track attendance, create workout plans, and record payments — all through a clean, dark-themed dashboard.

---

## Repository Structure

```
GymFitnessDB/
├── app.py                    ← Flask web application (updated)
├── README.md                 ← This file
│
├── sql/
│   ├── schema.sql            ← M4: CREATE TABLE statements (DDL)
│   ├── data_population.sql   ← M5: LOAD DATA / INSERT / UPDATE / DELETE
│   └── validation.sql        ← M5: Validation queries (COUNT, NULL, FK checks)
│
├── csv/
│   ├── members.csv           ← 100 rows synthetic data
│   ├── trainers.csv          ← 15 rows synthetic data
│   ├── workout_plans.csv     ← 80 rows synthetic data
│   ├── attendance.csv        ← 100 rows synthetic data
│   └── payments.csv          ← 100 rows synthetic data
│
├── docs/
│   ├── NORMALIZATION.md      ← M2: 1NF → 2NF → 3NF with justifications
│   ├── DATAFLOW.md           ← M3: Dataflow description
│   └── ERD.png               ← Updated ER Diagram
│
├── templates/
│   ├── base.html
│   ├── login.html
│   ├── dashboard.html
│   ├── index.html
│   ├── edit.html
│   ├── attendance.html
│   ├── payments.html
│   └── trainers.html
│
└── static/
    ├── style.css
    └── gym.jpg
```

---

## Database Schema (Normalized — 3NF)

```
Members(member_id PK, full_name, gender, phone, email, membership_type, join_date)
Trainers(trainer_id PK, trainer_name, specialization, phone)
Workout_Plans(plan_id PK, member_id FK, trainer_id FK, goal, duration_weeks)
Attendance(attendance_id PK, member_id FK, attendance_date, check_in_time, status)
Payments(payment_id PK, member_id FK, amount, payment_date, payment_status)
Admin(admin_id PK, username, password)
```

**Relationships:**
- Members → Workout_Plans: **1:N**
- Trainers → Workout_Plans: **1:N**
- Members → Attendance: **1:N**
- Members → Payments: **1:N**

---

## Setup Instructions

### Prerequisites
- Python 3.8+
- MySQL 8.0+
- pip

### Step 1 — Install Dependencies
```bash
pip install flask mysql-connector-python
```

### Step 2 — Create the Database
Open MySQL Workbench or MySQL CLI and run:
```sql
source sql/schema.sql
```

### Step 3 — Load Sample Data
```sql
source sql/data_population.sql
```

### Step 4 — Configure Database Password
Open `app.py` and update line 14:
```python
password="your_mysql_password_here"
```

### Step 5 — Run the Application
```bash
python app.py
```
Open your browser at: `http://127.0.0.1:5000/login`

**Default Login:**  
Username: `admin`  
Password: `admin123`

---

## Milestones Completed

| Milestone | Description | Status |
|---|---|---|
| M1 | Project Proposal & Initial ERD | ✅ Done |
| M2 | Normalization (1NF→3NF) + Updated ERD | ✅ Done |
| M3 | Synthetic Data (CSV) + Dataflow Documentation | ✅ Done |
| M4 | DDL Scripts + Indexes + Constraints | ✅ Done |
| M5 | Data Population + DML + Validation Queries | ✅ Done |

---

## Commit History

```
M2: Applied 1NF-3NF normalization, added status column to Attendance, updated ERD and schema
M3: Synthetic data generated (50-100 rows/table); dataflow documented
M4: DDL scripts added, EER diagram verified
M5: Data populated, validation queries added
```
