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
const { exec } = require('child_process');
const bcrypt = require('bcryptjs');
const User = require('./src/models/User');

function tryAdbReverse(port) {
  exec(`adb reverse tcp:${port} tcp:${port}`, (err, stdout) => {
    if (!err && stdout && stdout.trim().length > 0) {
      console.log(`[ADB] Port forwarding otomatis aktif untuk HP via USB: tcp:${port} -> tcp:${port}`);
    }
  });
}

// Menjaga agar port forwarding USB tidak putus saat HP terkunci atau kabel goyang
setInterval(() => {
  exec(`adb reverse tcp:${PORT} tcp:${PORT}`, () => {});
}, 3000);

async function seedDefaultUsers() {
  try {
    const adminPass = await bcrypt.hash('admin123', 10);
    const karyawanPass = await bcrypt.hash('karyawan123', 10);

    // 1. Pastikan Admin selalu ada
    const [adminUser, adminCreated] = await User.findOrCreate({
      where: { email: 'admin@mail.com' },
      defaults: {
        nama: 'Admin',
        email: 'admin@mail.com',
        password: adminPass,
        role: 'admin',
        jabatan: 'Administrator',
        is_active: true,
      },
    });
    if (!adminCreated && !adminUser.is_active) {
      adminUser.is_active = true;
      await adminUser.save();
    }

    // 2. Pastikan Karyawan Demo selalu ada
    const [karyawanUser, karyawanCreated] = await User.findOrCreate({
      where: { email: 'karyawan@mail.com' },
      defaults: {
        nama: 'Karyawan Demo',
        email: 'karyawan@mail.com',
        password: karyawanPass,
        role: 'karyawan',
        jabatan: 'Staff IT',
        no_hp: '081234567890',
        is_active: true,
      },
    });

    if (karyawanCreated) {
      console.log('✓ Akun Karyawan Demo (karyawan@mail.com) berhasil dibuat otomatis.');
    } else {
      // Pastikan password & status aktif jika user sudah ada sebelumnya
      const match = await bcrypt.compare('karyawan123', karyawanUser.password);
      if (!match || !karyawanUser.is_active) {
        karyawanUser.password = karyawanPass;
        karyawanUser.is_active = true;
        await karyawanUser.save();
        console.log('✓ Password & status akun Karyawan Demo disinkronkan kembali.');
      }
    }

    console.log('✓ Akun default demo (admin & karyawan) siap digunakan.');
  } catch (err) {
    console.warn('Gagal seed default users:', err.message);
  }
}

sequelize
  .sync() // ganti { alter: true } saat development kalau skema berubah
  .then(async () => {
    console.log('Database terhubung & model tersinkronisasi');
    await seedDefaultUsers();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server jalan di port ${PORT} (http://0.0.0.0:${PORT})`);
      tryAdbReverse(PORT);
    });
  })
  .catch((err) => {
    console.error('Gagal konek ke database:', err.message);
  });
