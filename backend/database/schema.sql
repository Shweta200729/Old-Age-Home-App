-- Drop tables if they exist (Clean Slate)
DROP TABLE IF EXISTS daily_reports;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS elderly;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS old_age_homes;

-- Old Age Homes table
CREATE TABLE old_age_homes (
    id SERIAL PRIMARY KEY,
    name TEXT,
    location TEXT,
    district TEXT,
    residents_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'active'
);

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT UNIQUE,
    password TEXT,
    role TEXT CHECK(role IN ('admin', 'government', 'caretaker')),
    status TEXT DEFAULT 'pending',
    old_age_home_id INTEGER REFERENCES old_age_homes(id) ON DELETE SET NULL
);

-- Elderly table
CREATE TABLE elderly (
    id SERIAL PRIMARY KEY,
    name TEXT,
    age INTEGER,
    health_status TEXT DEFAULT 'Good',
    gender TEXT,
    room TEXT,
    medical_conditions TEXT,
    emergency_contact TEXT,
    admission_date TEXT,
    old_age_home_id INTEGER REFERENCES old_age_homes(id) ON DELETE CASCADE,
    caretaker_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Reports table (Basic health status)
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    elderly_id INTEGER REFERENCES elderly(id) ON DELETE CASCADE,
    health_report TEXT,
    date TEXT
);

-- Daily Activity Reports table (Detailed)
CREATE TABLE daily_reports (
    id SERIAL PRIMARY KEY,
    elderly_id INTEGER REFERENCES elderly(id) ON DELETE CASCADE,
    date TEXT,
    breakfast INTEGER, -- 0 or 1
    lunch INTEGER,
    dinner INTEGER,
    medicine_given INTEGER,
    medicine_time TEXT,
    physical_activity TEXT,
    bathing INTEGER,
    clothes_changed INTEGER,
    mood TEXT,
    issues TEXT,
    photo_path TEXT
);

-- Feedbacks table
CREATE TABLE feedbacks (
    id SERIAL PRIMARY KEY,
    old_age_home_id INTEGER REFERENCES old_age_homes(id) ON DELETE CASCADE,
    government_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    rating INTEGER CHECK(rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
