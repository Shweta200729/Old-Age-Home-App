const db = require('./database/db_postgres');

async function migrate() {
  try {
    console.log("Adding is_acknowledged to daily_reports...");
    await db.query("ALTER TABLE daily_reports ADD COLUMN IF NOT EXISTS is_acknowledged BOOLEAN DEFAULT FALSE;");
    
    console.log("Adding is_acknowledged to facility_reports...");
    await db.query("ALTER TABLE facility_reports ADD COLUMN IF NOT EXISTS is_acknowledged BOOLEAN DEFAULT FALSE;");

    console.log("Migration completed successfully.");
  } catch (err) {
    console.error("Migration error:", err.message);
  }
  process.exit(0);
}

migrate();
