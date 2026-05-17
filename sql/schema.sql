-- =============================================================
-- GymFitnessDB - DDL SCHEMA (Milestone 4)
-- Author: Ali Hassan & Muhammad Huzaifa
-- Description: Normalized schema for Gym & Fitness Tracker System
-- =============================================================

CREATE DATABASE IF NOT EXISTS GymFitnessDB;
USE GymFitnessDB;

-- =========================
-- MEMBERS TABLE
-- =========================
CREATE TABLE Members (
    member_id       INT PRIMARY KEY AUTO_INCREMENT,
    full_name       VARCHAR(100) NOT NULL,
    gender          ENUM('Male', 'Female') NOT NULL,
    phone           VARCHAR(20) UNIQUE NOT NULL,
    email           VARCHAR(100) UNIQUE,
    membership_type VARCHAR(50) NOT NULL,
    join_date       DATE NOT NULL
);

-- Index for fast lookup by membership type
CREATE INDEX idx_members_membership ON Members(membership_type);

-- =========================
-- TRAINERS TABLE
-- =========================
CREATE TABLE Trainers (
    trainer_id      INT PRIMARY KEY AUTO_INCREMENT,
    trainer_name    VARCHAR(100) NOT NULL,
    specialization  VARCHAR(100),
    phone           VARCHAR(20) UNIQUE NOT NULL
);

-- =========================
-- WORKOUT PLANS TABLE
-- =========================
CREATE TABLE Workout_Plans (
    plan_id         INT PRIMARY KEY AUTO_INCREMENT,
    member_id       INT NOT NULL,
    trainer_id      INT NOT NULL,
    goal            VARCHAR(100),
    duration_weeks  INT CHECK(duration_weeks > 0),
    FOREIGN KEY (member_id)  REFERENCES Members(member_id)  ON DELETE CASCADE,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id) ON DELETE RESTRICT
);

-- Indexes on foreign keys for JOIN performance
CREATE INDEX idx_wp_member   ON Workout_Plans(member_id);
CREATE INDEX idx_wp_trainer  ON Workout_Plans(trainer_id);

-- =========================
-- ATTENDANCE TABLE
-- =========================
CREATE TABLE Attendance (
    attendance_id   INT PRIMARY KEY AUTO_INCREMENT,
    member_id       INT NOT NULL,
    attendance_date DATE NOT NULL,
    check_in_time   TIME,
    status          ENUM('Present', 'Absent') NOT NULL DEFAULT 'Present',
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- Index on member_id and date for quick daily lookups
CREATE INDEX idx_att_member ON Attendance(member_id);
CREATE INDEX idx_att_date   ON Attendance(attendance_date);

-- =========================
-- PAYMENTS TABLE
-- =========================
CREATE TABLE Payments (
    payment_id      INT PRIMARY KEY AUTO_INCREMENT,
    member_id       INT NOT NULL,
    amount          DECIMAL(10,2) NOT NULL CHECK(amount > 0),
    payment_date    DATE NOT NULL,
    payment_status  ENUM('Paid', 'Pending') NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- Index on member_id and status for payment queries
CREATE INDEX idx_pay_member ON Payments(member_id);
CREATE INDEX idx_pay_status ON Payments(payment_status);

-- =========================
-- ADMIN TABLE (for login)
-- =========================
CREATE TABLE Admin (
    admin_id    INT PRIMARY KEY AUTO_INCREMENT,
    username    VARCHAR(50) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL
);

-- Default admin account
INSERT INTO Admin (username, password) VALUES ('admin', 'admin123');
