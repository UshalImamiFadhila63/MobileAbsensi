const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// LOGIN -> sesuai flow: input email & password -> cek benar/salah -> dashboard sesuai role
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email dan password wajib diisi' });
    }

    const user = await User.findOne({ where: { email } });

    if (!user || !user.is_active) {
      return res.status(401).json({ message: 'Email atau password salah' });
    }

    const cocok = await bcrypt.compare(password, user.password);
    if (!cocok) {
      return res.status(401).json({ message: 'Email atau password salah' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    res.json({
      message: 'Login berhasil',
      token,
      user: {
        id: user.id,
        nama: user.nama,
        email: user.email,
        role: user.role,
        jabatan: user.jabatan,
        foto_profil: user.foto_profil,
      },
    });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// dipanggil dari halaman profile setelah login (POP UP PROFILE di flow)
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password'] },
    });
    if (!user) return res.status(404).json({ message: 'User tidak ditemukan' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { nama, no_hp, jabatan } = req.body;
    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ message: 'User tidak ditemukan' });

    if (nama) user.nama = nama;
    if (no_hp) user.no_hp = no_hp;
    if (jabatan) user.jabatan = jabatan;
    if (req.file) user.foto_profil = `/uploads/profil/${req.file.filename}`;

    await user.save();
    res.json({ message: 'Profil berhasil diperbarui', user });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// logout ditangani di sisi client (hapus token tersimpan), endpoint ini opsional untuk logging
exports.logout = async (req, res) => {
  res.json({ message: 'Logout berhasil' });
};
