require('dotenv').config();
const bcrypt = require('bcryptjs');
const sequelize = require('../src/config/db');
const User = require('../src/models/User');

async function seed() {
  try {
    await sequelize.authenticate();
    console.log('Database terhubung.');

    const adminPass = await bcrypt.hash('admin123', 10);
    const karyawanPass = await bcrypt.hash('karyawan123', 10);

    const [admin, adminCreated] = await User.findOrCreate({
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

    const [karyawan, karyawanCreated] = await User.findOrCreate({
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

    if (!karyawanCreated) {
      karyawan.password = karyawanPass;
      karyawan.is_active = true;
      await karyawan.save();
    }

    console.log('Akun Admin:', admin.email, adminCreated ? '(Baru dibuat)' : '(Sudah ada)');
    console.log('Akun Karyawan:', karyawan.email, karyawanCreated ? '(Baru dibuat)' : '(Sudah ada & disinkronkan)');
    console.log('Selesai!');
    process.exit(0);
  } catch (err) {
    console.error('Gagal seed:', err.message);
    process.exit(1);
  }
}

seed();
