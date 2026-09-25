const multer = require('multer');
const path = require('path');
const fs = require('fs');

function makeUploader(folder) {
  const dir = path.join(__dirname, '..', '..', 'uploads', folder);
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, dir),
    filename: (req, file, cb) => {
      const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
      cb(null, unique + path.extname(file.originalname));
    },
  });

  return multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
    fileFilter: (req, file, cb) => {
      const allowed = /jpeg|jpg|png/;
      const ok = allowed.test(path.extname(file.originalname).toLowerCase());
      cb(ok ? null : new Error('Hanya file gambar (jpg/png) yang diperbolehkan'), ok);
    },
  });
}

module.exports = { makeUploader };
