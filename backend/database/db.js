const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Connect to SQLite DB
const dbPath = path.resolve(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error connecting to SQLite database:', err.message);
  } else {
    console.log('Connected to the SQLite database.');

    // Create tables
    db.serialize(() => {
      // Old Age Homes table
      db.run(`CREATE TABLE IF NOT EXISTS old_age_homes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        location TEXT,
        district TEXT,
        residents_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active'
      )`);

      // Users table (updated to include old_age_home_id and avatar_url)
      db.run(`CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        role TEXT CHECK(role IN ('admin', 'government', 'caretaker')),
        status TEXT DEFAULT 'pending',
        old_age_home_id INTEGER,
        avatar_url TEXT,
        FOREIGN KEY (old_age_home_id) REFERENCES old_age_homes(id)
      )`);

      // Migration: Add old_age_home_id if it's missing (SQLite only)
      db.run(`ALTER TABLE users ADD COLUMN old_age_home_id INTEGER`, (err) => {
        if (err) {
          // If the column already exists, this will error (which we can ignore)
          if (!err.message.includes('duplicate column name')) {
             console.log('Note: users table already has old_age_home_id or encountered other issue:', err.message);
          }
        } else {
          console.log('Successfully migrated users table with old_age_home_id column.');
        }
      });

      // Migration: Add avatar_url if it's missing (SQLite only)
      db.run(`ALTER TABLE users ADD COLUMN avatar_url TEXT`, (err) => {
        if (err && !err.message.includes('duplicate column name')) {
          console.log('Note: users table already has avatar_url or encountered other issue:', err.message);
        }
      });

      // Elderly table (updated with more fields)
      db.run(`CREATE TABLE IF NOT EXISTS elderly (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        age INTEGER,
        gender TEXT,
        room TEXT,
        medical_conditions TEXT,
        emergency_contact TEXT,
        admission_date TEXT,
        old_age_home_id INTEGER,
        caretaker_id INTEGER,
        FOREIGN KEY (old_age_home_id) REFERENCES old_age_homes(id),
        FOREIGN KEY (caretaker_id) REFERENCES users(id)
      )`);

      // Migration for elderly table (SQLite only)
      const elderlyColumns = [
        'gender TEXT',
        'room TEXT',
        'medical_conditions TEXT',
        'emergency_contact TEXT',
        'admission_date TEXT',
        'old_age_home_id INTEGER'
      ];

      elderlyColumns.forEach(columnDef => {
        const columnName = columnDef.split(' ')[0];
        db.run(`ALTER TABLE elderly ADD COLUMN ${columnDef}`, (err) => {
          if (err && !err.message.includes('duplicate column name')) {
            console.log(`Note: Adding ${columnName} to elderly table failed or already exists:`, err.message);
          }
        });
      });

      // Reports table (Basic health status)
      db.run(`CREATE TABLE IF NOT EXISTS reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elderly_id INTEGER,
        health_report TEXT,
        date TEXT,
        FOREIGN KEY (elderly_id) REFERENCES elderly(id)
      )`);

      // Daily Activity Reports table (Detailed)
      db.run(`CREATE TABLE IF NOT EXISTS daily_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        elderly_id INTEGER,
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
        photo_path TEXT,
        FOREIGN KEY (elderly_id) REFERENCES elderly(id)
      )`);

      // Feedbacks table
      db.run(`CREATE TABLE IF NOT EXISTS feedbacks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        old_age_home_id INTEGER,
        government_id INTEGER,
        rating INTEGER CHECK(rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (old_age_home_id) REFERENCES old_age_homes(id),
        FOREIGN KEY (government_id) REFERENCES users(id)
      )`);

      console.log('Database tables ensured.');
    });
  }
});

module.exports = db;
