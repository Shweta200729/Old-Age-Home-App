const db = require('../database/db_postgres');

exports.createUser = async (req, res) => {
  const { name, email, password, role } = req.body;
  if (!name || !email || !password || !role) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  // Auto approve admin and government users natively.
  const status = role === 'caretaker' ? 'pending' : 'approved';

  try {
    const query = 'INSERT INTO users (name, email, password, role, status) VALUES ($1, $2, $3, $4, $5)';
    const result = await db.run(query, [name, email, password, role, status]);
    res.status(201).json({ message: 'User created', id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create user' });
  }
};

exports.deleteUser = async (req, res) => {
  const { id } = req.params;
  try {
    const query = 'DELETE FROM users WHERE id = $1';
    const result = await db.run(query, [id]);
    if (result.changes === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ message: 'User deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete user' });
  }
};

exports.viewAllData = async (req, res) => {
  try {
    const [users, elderly, reports, homes, dailyReports] = await Promise.all([
      db.all('SELECT * FROM users'),
      db.all('SELECT * FROM elderly'),
      db.all('SELECT * FROM reports'),
      db.all('SELECT * FROM old_age_homes'),
      db.all(`
        SELECT d.*, e.name AS elderly_name, h.name AS home_name, h.id AS home_id 
        FROM daily_reports d 
        JOIN elderly e ON d.elderly_id = e.id 
        JOIN old_age_homes h ON e.old_age_home_id = h.id 
        ORDER BY d.id DESC
      `)
    ]);

    res.json({
      users,
      elderly,
      reports,
      homes,
      daily_reports: dailyReports
    });
  } catch (err) {
    console.error('Error fetching dashboard data:', err.message);
    res.status(500).json({ error: 'Error fetching dashboard data' });
  }
};

exports.addResident = async (req, res) => {
  const { name, age, gender, room, medical_conditions, emergency_contact, admission_date, old_age_home_id, relative_name, relative_email } = req.body;
  
  if (!name || !age || !old_age_home_id) {
    return res.status(400).json({ error: 'Name, age, and old_age_home_id are required' });
  }

  try {
    const query = `
      INSERT INTO elderly (name, age, gender, room, medical_conditions, emergency_contact, admission_date, old_age_home_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING id
    `;
    const result = await db.pool.query(query, [name, age, gender, room, medical_conditions, emergency_contact, admission_date, old_age_home_id]);
    const elderly_id = result.rows[0].id;
    
    let relative_password = null;
    
    if (relative_name && relative_email) {
      relative_password = Math.random().toString(36).slice(-8);
      const userQuery = `
        INSERT INTO users (name, email, password, role, status, elderly_id)
        VALUES ($1, $2, $3, 'relative', 'approved', $4)
      `;
      try {
        await db.pool.query(userQuery, [relative_name, relative_email, relative_password, elderly_id]);
      } catch (err) {
        if (err.code === '23505') {
          console.error("Relative email already exists:", relative_email);
          relative_password = null;
        } else {
          throw err;
        }
      }
    }

    res.status(201).json({ 
      message: 'Resident added successfully', 
      id: elderly_id,
      relative_password: relative_password,
      relative_email: relative_password ? relative_email : null
    });
  } catch (err) {
    console.error('Error adding resident:', err.message);
    res.status(500).json({ error: 'Failed to add resident' });
  }
};

exports.getResidentsByHome = async (req, res) => {
  const { home_id } = req.params;
  try {
    const query = 'SELECT * FROM elderly WHERE old_age_home_id = $1';
    const rows = await db.all(query, [home_id]);
    res.json({ residents: rows });
  } catch (err) {
    console.error('Error fetching residents:', err.message);
    res.status(500).json({ error: 'Failed to fetch residents' });
  }
};

exports.assignCaretaker = async (req, res) => {
  const { elderly_id } = req.params;
  const { caretaker_id } = req.body;
  
  if (!caretaker_id) return res.status(400).json({ error: 'caretaker_id is required' });

  try {
    // Verify caretaker exists
    const user = await db.get('SELECT id FROM users WHERE id = $1 AND role = \'caretaker\'', [caretaker_id]);
    if (!user) return res.status(404).json({ error: 'Caretaker not found' });

    const query = 'UPDATE elderly SET caretaker_id = $1 WHERE id = $2';
    const result = await db.run(query, [caretaker_id, elderly_id]);
    if (result.changes === 0) return res.status(404).json({ error: 'Elderly not found' });
    res.json({ message: 'Caretaker assigned successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to assign caretaker' });
  }
};
