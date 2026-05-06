const db = require('../database/db_postgres');

exports.viewAllElderly = async (req, res) => {
  try {
    const query = 'SELECT * FROM elderly';
    const rows = await db.all(query);
    res.json({ elderly: rows });
  } catch (err) {
    res.status(500).json({ error: 'Failed to retrieve elderly data' });
  }
};

exports.viewReports = async (req, res) => {
  try {
    const query = `
      SELECT d.*, e.name AS elderly_name, h.name AS home_name, h.id AS home_id 
      FROM daily_reports d 
      JOIN elderly e ON d.elderly_id = e.id
      JOIN old_age_homes h ON e.old_age_home_id = h.id
      ORDER BY d.id DESC
    `;
    const rows = await db.all(query);
    res.json({ reports: rows });
  } catch (err) {
    res.status(500).json({ error: 'Failed to retrieve reports' });
  }
};

exports.approveRejectHome = async (req, res) => {
  const { id } = req.params; // Caretaker (Home) user ID
  const { status } = req.body; // 'approved' or 'rejected'
  
  if (!['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ error: 'Status must be approved or rejected' });
  }

  try {
    const query = 'UPDATE users SET status = $1 WHERE id = $2 AND role = \'caretaker\'';
    const result = await db.run(query, [status, id]);
    if (result.changes === 0) return res.status(404).json({ error: 'Caretaker (Home) not found' });
    res.json({ message: `Home status updated to ${status}` });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update home status' });
  }
};

exports.getDailyReportsByHome = async (req, res) => {
  const { home_id } = req.params;
  
  try {
    const query = `
      SELECT dr.*, e.name AS elderly_name, e.room, u.name AS caretaker_name
      FROM daily_reports dr
      JOIN elderly e ON dr.elderly_id = e.id
      LEFT JOIN users u ON e.caretaker_id = u.id
      WHERE e.old_age_home_id = $1
      ORDER BY dr.date DESC
    `;
    const rows = await db.all(query, [home_id]);
    res.json({ reports: rows });
  } catch (err) {
    console.error('Error fetching daily reports:', err.message);
    res.status(500).json({ error: 'Failed to fetch daily reports' });
  }
};

exports.submitFeedback = async (req, res) => {
  const { old_age_home_id, government_id, rating, comment } = req.body;
  
  if (!old_age_home_id || !rating || !comment) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const query = 'INSERT INTO feedbacks (old_age_home_id, government_id, rating, comment) VALUES ($1, $2, $3, $4) RETURNING *';
    const result = await db.run(query, [old_age_home_id, government_id, rating, comment]);
    res.status(201).json({ message: 'Feedback submitted successfully', feedback: result });
  } catch (err) {
    console.error('Error submitting feedback:', err.message);
    res.status(500).json({ error: 'Failed to submit feedback' });
  }
};

exports.getFeedbackByHome = async (req, res) => {
  const { id } = req.params;
  
  try {
    const query = `
      SELECT f.*, u.name AS government_name, u.avatar_url AS government_avatar
      FROM feedbacks f
      LEFT JOIN users u ON f.government_id = u.id
      WHERE f.old_age_home_id = $1
      ORDER BY f.created_at DESC
    `;
    const rows = await db.all(query, [id]);
    res.json({ feedbacks: rows });
  } catch (err) {
    console.error('Error fetching feedbacks:', err.message);
    res.status(500).json({ error: 'Failed to fetch feedbacks' });
  }
};
