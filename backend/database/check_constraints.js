const db = require('./db_postgres');
async function run() {
  try {
    const res = await db.all("SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'users'::regclass");
    console.log(res);
  } catch(e) {
    console.log(e);
  }
  process.exit(0);
}
run();
