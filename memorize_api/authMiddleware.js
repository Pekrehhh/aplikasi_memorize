const jwt = require('jsonwebtoken');

// Ini adalah "Satpam" kita
const authMiddleware = (req, res, next) => {
  // 1. Ambil token dari header 'Authorization'
  // Formatnya akan seperti: "Bearer <token...>"
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Ambil token-nya saja

  // 2. Cek apakah token ada?
  if (token == null) {
    // 401 = Unauthorized (Tidak punya izin)
    return res.status(401).json({ message: 'Akses ditolak. Token dibutuhkan.' });
  }

  // 3. Verifikasi token (tiket)
  jwt.verify(token, process.env.JWT_SECRET, (err, payload) => {
    if (err) {
      // 403 = Forbidden (Izin ditolak/Token tidak valid)
      return res.status(403).json({ message: 'Token tidak valid.' });
    }

    // 4. Jika token valid, simpan info pengguna di 'req'
    // 'payload' berisi { userId: ... } yang kita buat saat login
    req.user = payload; 

    // 5. Lanjutkan ke endpoint (misal: ke 'buat notes')
    next(); 
  });
};

module.exports = authMiddleware; // Ekspor "Satpam" ini agar bisa dipakai