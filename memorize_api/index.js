require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const authMiddleware = require('./authMiddleware');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const fs = require('fs');
    const dir = 'uploads';
    if (!fs.existsSync(dir)){
        fs.mkdirSync(dir);
    }
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + path.extname(file.originalname);
    cb(null, req.user.userId + '-' + uniqueSuffix);
  }
});

const upload = multer({ storage: storage });

app.get('/', (req, res) => {
  res.send('Halo! API Memorize sudah menyala!');
});

app.get('/testdb', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      message: 'Koneksi ke database BERHASIL!',
      time: result.rows[0].now,
    });
  } catch (err) {
    res.status(500).send('Koneksi ke database GAGAL!');
  }
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: 'Username, email, dan password dibutuhkan' });
    }
    
    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await pool.query(
      "INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING id, email, username",
      [username, email, hashedPassword]
    );

    res.status(201).json({
      message: 'User berhasil terdaftar!',
      user: newUser.rows[0]
    });

  } catch (err) {
    console.error(err.message);
    if (err.code === '23505') { 
      if (err.detail.includes('email')) {
        return res.status(400).json({ message: 'Email sudah terdaftar.' });
      }
      if (err.detail.includes('username')) {
        return res.status(400).json({ message: 'Username sudah digunakan.' });
      }
    }
    res.status(500).json({ message: 'Terjadi error pada server' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ message: 'Username dan password dibutuhkan' });
    }

    const userResult = await pool.query(
      "SELECT * FROM users WHERE username = $1",
      [username]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const user = userResult.rows[0];

    const isPasswordMatch = await bcrypt.compare(password, user.password);

    if (!isPasswordMatch) {
      return res.status(401).json({ message: 'Username atau password salah' });
    }

    const token = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.status(200).json({
      message: 'Login berhasil!',
      token: token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        profile_image_url: user.profile_image_url
      }
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Terjadi error pada server' });
  }
});

app.post('/api/notes', authMiddleware, async (req, res) => {
  try {
    const { title, content, color, reminder_at } = req.body;
    const userId = req.user.userId; 
    const newNote = await pool.query(
      "INSERT INTO notes (user_id, title, content, color, reminder_at) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [userId, title, content, color, reminder_at]
    );

    res.status(201).json(newNote.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error saat membuat note" });
  }
});

app.get('/api/notes', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const allNotes = await pool.query(
      "SELECT * FROM notes WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );

    res.status(200).json(allNotes.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error saat mengambil notes" });
  }
});

app.put('/api/notes/:id', authMiddleware, async (req, res) => {
  try {
    const noteId = req.params.id;
    const userId = req.user.userId;
    const { title, content, color, reminder_at } = req.body;
    const updateNote = await pool.query(
      "UPDATE notes SET title = $1, content = $2, color = $3, reminder_at = $4 WHERE id = $5 AND user_id = $6 RETURNING *",
      [title, content, color, reminder_at, noteId, userId]
    );

    if (updateNote.rows.length === 0) {
      return res.status(404).json({ message: "Note tidak ditemukan atau Anda tidak punya izin" });
    }

    res.status(200).json(updateNote.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error saat update note" });
  }
});

app.delete('/api/notes/:id', authMiddleware, async (req, res) => {
  try {
    const noteId = req.params.id;
    const userId = req.user.userId;
    const deleteNote = await pool.query(
      "DELETE FROM notes WHERE id = $1 AND user_id = $2 RETURNING *",
      [noteId, userId]
    );

    if (deleteNote.rows.length === 0) {
      return res.status(404).json({ message: "Note tidak ditemukan atau Anda tidak punya izin" });
    }

    res.status(200).json({ message: "Note berhasil dihapus" });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error saat menghapus note" });
  }
});

app.get('/api/profile/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const userResult = await pool.query(
      "SELECT id, email, profile_image_url, saran_kesan FROM users WHERE id = $1",
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    res.json(userResult.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error" });
  }
});

app.post('/api/profile/upload', [authMiddleware, upload.single('profileImage')], async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Tidak ada file yang di-upload' });
    }

    const userId = req.user.userId;
    const imageUrl = '/uploads/' + req.file.filename;

    const updateResult = await pool.query(
      "UPDATE users SET profile_image_url = $1 WHERE id = $2 RETURNING profile_image_url",
      [imageUrl, userId]
    );

    res.json({
      message: 'Upload berhasil',
      profile_image_url: updateResult.rows[0].profile_image_url
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error" });
  }
});

app.put('/api/profile/saran-kesan', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { saran_kesan } = req.body;

    if (saran_kesan === undefined) {
      return res.status(400).json({ message: 'saran_kesan dibutuhkan' });
    }

    const updateResult = await pool.query(
      "UPDATE users SET saran_kesan = $1 WHERE id = $2 RETURNING saran_kesan",
      [saran_kesan, userId]
    );

    if (updateResult.rows.length === 0) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    res.json({
      message: 'Saran & Kesan berhasil diupdate',
      saran_kesan: updateResult.rows[0].saran_kesan
    });

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: "Server error" });
  }
});

app.listen(port, () => {
  console.log(`Server API berjalan di http://localhost:${port}`);
});

app.get('/api/config/keys', (req, res) => {
  res.json({
    timezoneDbApiKey: process.env.TIMEZONE_DB_API_KEY 
  });
});