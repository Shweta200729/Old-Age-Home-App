const db = require('../database/db_postgres');

exports.register = async (req, res) => {
  const { name, email, password, role, old_age_home_id, avatar_url } = req.body;

  // Basic validation
  if (!name || !email || !password || !role) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    // Insert user
    const query = 'INSERT INTO users (name, email, password, role, old_age_home_id, avatar_url) VALUES ($1, $2, $3, $4, $5, $6)';
    const result = await db.run(query, [name, email, password, role, old_age_home_id || null, avatar_url || null]);
    
    return res.status(201).json({
      message: 'Registration successful',
      user: {
        id: result.lastID, // Note: In Postgres we might need RETURNING id to get lastID accurately if it's not Serial
        name,
        email,
        role,
        old_age_home_id,
        avatar_url
      }
    });
  } catch (err) {
    // Postgres numeric code for unique_violation is 23505
    if (err.code === '23505') {
      return res.status(409).json({ error: 'Email already exists' });
    }
    console.error('Registration error:', err.message);
    return res.status(500).json({ error: 'Failed to register user' });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const query = `
      SELECT u.id, u.name, u.email, u.role, u.old_age_home_id, u.avatar_url, u.elderly_id, h.name AS old_age_home_name
      FROM users u
      LEFT JOIN old_age_homes h ON u.old_age_home_id = h.id
      WHERE u.email = $1 AND u.password = $2
    `;
    const user = await db.get(query, [email, password]);
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    return res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        old_age_home_id: user.old_age_home_id,
        old_age_home_name: user.old_age_home_name,
        avatar_url: user.avatar_url,
        elderly_id: user.elderly_id
      }
    });
  } catch (err) {
    console.error('Database error during login:', err.message);
    return res.status(500).json({ error: `Database error during login: ${err.message}` });
  }
};
