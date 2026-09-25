require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const sequelize = require('./src/config/db');

// models (perlu di-require supaya asosiasi & sync jalan)
require('./src/models/User');
require('./src/models/Absensi');
require('./src/models/Cuti');
require('./src/models/Laporan');

const authRoutes = require('./src/routes/authRoutes');
const absensiRoutes = require('./src/routes/absensiRoutes');
const cutiRoutes = require('./src/routes/cutiRoutes');
const laporanRoutes = require('./src/routes/laporanRoutes');
const karyawanRoutes = require('./src/routes/karyawanRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// akses file foto absen/cuti/laporan/profil
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/absensi', absensiRoutes);
app.use('/api/cuti', cutiRoutes);
app.use('/api/laporan', laporanRoutes);
app.use('/api/karyawan', karyawanRoutes);

app.get('/', (req, res) => res.json({ message: 'Absensi API aktif' }));

const PORT = process.env.PORT || 3000;

sequelize
  .sync() // ganti { alter: true } saat development kalau skema berubah
  .then(() => {
    console.log('Database terhubung & model tersinkronisasi');
    app.listen(PORT, () => console.log(`Server jalan di port ${PORT}`));
  })
  .catch((err) => {
    console.error('Gagal konek ke database:', err.message);
  });
