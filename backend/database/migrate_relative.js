const db = require('./db_postgres');

async function migrate() {
  try {
    console.log('Starting migration...');
    
    // Drop existing constraint
    await db.query(`ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check`);
    console.log('Dropped users_role_check constraint');
    
    // Add new constraint
    await db.query(`ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('admin', 'government', 'caretaker', 'relative'))`);
    console.log('Added updated users_role_check constraint');
    
    // Add elderly_id column to users table
    await db.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS elderly_id INTEGER REFERENCES elderly(id) ON DELETE SET NULL`);
    console.log('Added elderly_id column to users table');
    
    console.log('Migration successful.');
  } catch (error) {
    console.error('Migration failed:', error);
  } finally {
    process.exit(0);
  }
}

migrate();
