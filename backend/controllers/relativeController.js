const db = require('../database/db_postgres');

exports.getResidentReports = async (req, res) => {
  const { elderly_id } = req.params;
  
  if (!elderly_id) {
    return res.status(400).json({ error: 'Elderly ID is required' });
  }

  try {
    const elderly = await db.get('SELECT * FROM elderly WHERE id = $1', [elderly_id]);
    if (!elderly) {
      return res.status(404).json({ error: 'Resident not found' });
    }

    const daily_reports = await db.all('SELECT * FROM daily_reports WHERE elderly_id = $1 ORDER BY id DESC', [elderly_id]);
    const health_reports = await db.all('SELECT * FROM reports WHERE elderly_id = $1 ORDER BY id DESC', [elderly_id]);
    
    res.json({
      resident: elderly,
      daily_reports,
      health_reports
    });
  } catch (err) {
    console.error('Error fetching relative reports:', err.message);
    res.status(500).json({ error: 'Failed to fetch reports' });
  }
};
