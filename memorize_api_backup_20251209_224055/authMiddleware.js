const jwt = require('jsonwebtoken');
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (token == null) {
    return res.status(401).json({ message: 'Akses ditolak. Token dibutuhkan.' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, payload) => {
    if (err) {
      return res.status(403).json({ message: 'Token tidak valid.' });
    }
    
    req.user = payload; 
    next(); 
  });
};

module.exports = authMiddleware;