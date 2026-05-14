const db = require('../database/db_postgres');

exports.addElderly = async (req, res) => {
  const { name, age, health_status, caretaker_id } = req.body;
  if (!name || !age || !caretaker_id) {
    return res.status(400).json({ error: 'Name, age, and caretaker_id are required' });
  }

  try {
    const query = 'INSERT INTO elderly (name, age, health_status, caretaker_id) VALUES ($1, $2, $3, $4)';
    const result = await db.run(query, [name, age, health_status || 'Good', caretaker_id]);
    res.status(201).json({ message: 'Elderly added successfully', id: result.lastID });
  } catch (err) {
    res.status(500).json({ error: 'Failed to add elderly person' });
  }
};

exports.updateHealthStatus = async (req, res) => {
  const { id } = req.params;
  const { health_status, health_report } = req.body;
  
  if (!health_status) return res.status(400).json({ error: 'health_status is required' });

  try {
    const query = 'UPDATE elderly SET health_status = $1 WHERE id = $2';
    await db.run(query, [health_status, id]);
    
    // Insert into reports table if health_report is provided
    if (health_report) {
      const reportQuery = 'INSERT INTO reports (elderly_id, health_report, date) VALUES ($1, $2, $3)';
      await db.run(reportQuery, [id, health_report, new Date().toISOString()]);
    }
    
    res.json({ message: 'Health status updated successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update health status' });
  }
};

exports.viewAssignedElderly = async (req, res) => {
  const { caretaker_id } = req.params;
  
  try {
    // First get the old_age_home_id of this caretaker
    const user = await db.get('SELECT old_age_home_id FROM users WHERE id = $1', [caretaker_id]);
    if (!user) return res.status(404).json({ error: 'Caretaker not found' });
    
    // Show all elderly persons belonging to the same home
    const query = 'SELECT * FROM elderly WHERE old_age_home_id = $1 OR caretaker_id = $2';
    const rows = await db.all(query, [user.old_age_home_id, caretaker_id]);
    res.json({ elderly: rows });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch elderly data' });
  }
};

exports.addDailyReport = async (req, res) => {
  const {
    elderly_id,
    date,
    breakfast,
    lunch,
    dinner,
    medicine_given,
    medicine_time,
    physical_activity,
    bathing,
    clothes_changed,
    mood,
    issues,
    photo_path
  } = req.body;

  if (!elderly_id || !date) {
    return res.status(400).json({ error: 'elderly_id and date are required' });
  }

  if (!photo_path || photo_path.trim() === '') {
    return res.status(400).json({ error: 'Photo proof is mandatory for daily reports' });
  }

  try {
    const query = `
      INSERT INTO daily_reports (
        elderly_id, date, breakfast, lunch, dinner, 
        medicine_given, medicine_time, physical_activity, 
        bathing, clothes_changed, mood, issues, photo_path
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
    `;

    const params = [
      elderly_id, date, breakfast ? 1 : 0, lunch ? 1 : 0, dinner ? 1 : 0,
      medicine_given ? 1 : 0, medicine_time, physical_activity,
      bathing ? 1 : 0, clothes_changed ? 1 : 0, mood, issues, photo_path
    ];

    const result = await db.run(query, params);
    
    // Also update health status in elderly table
    const statusQuery = 'UPDATE elderly SET health_status = $1 WHERE id = $2';
    const status = issues && issues.trim().length > 0 ? 'attention' : 'good';
    await db.run(statusQuery, [status, elderly_id]);

    res.status(201).json({ message: 'Daily report added successfully', id: result.lastID });
  } catch (err) {
    console.error('Error adding daily report:', err.message);
    res.status(500).json({ error: 'Failed to add daily report' });
  }
};

exports.addFacilityReport = async (req, res) => {
  const { caretaker_id, old_age_home_id, date, bathroom_image, food_image, cleanliness_image } = req.body;

  if (!caretaker_id || !old_age_home_id || !date || !bathroom_image || !food_image || !cleanliness_image) {
    return res.status(400).json({ error: 'All fields including 3 images are required' });
  }

  try {
    const query = `
      INSERT INTO facility_reports (
        caretaker_id, old_age_home_id, date, bathroom_image, food_image, cleanliness_image
      ) VALUES ($1, $2, $3, $4, $5, $6)
    `;

    const params = [caretaker_id, old_age_home_id, date, bathroom_image, food_image, cleanliness_image];
    const result = await db.run(query, params);

    res.status(201).json({ message: 'Facility report added successfully', id: result.lastID });
  } catch (err) {
    console.error('Error adding facility report:', err.message);
    res.status(500).json({ error: 'Failed to add facility report' });
  }
};
