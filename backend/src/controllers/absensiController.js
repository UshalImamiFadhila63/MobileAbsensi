const { Op } = require('sequelize');
const Absensi = require('../models/Absensi');
const User = require('../models/User');
const { isDalamRadiusKantor } = require('../utils/geo');

function hariIni() {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD
}

function jamSekarang() {
  return new Date().toTimeString().slice(0, 8); // HH:MM:SS
}

// ABSENSI MASUK: ambil foto + validasi GPS
exports.absenMasuk = async (req, res) => {
  try {
    const { lat, lng } = req.body;
    if (!lat || !lng) {
      return res.status(400).json({ message: 'Lokasi (lat, lng) wajib dikirim' });
    }
    if (!req.file) {
      return res.status(400).json({ message: 'Foto absen wajib diupload' });
    }

    const { valid, jarak } = isDalamRadiusKantor(parseFloat(lat), parseFloat(lng));
    if (!valid) {
      return res.status(400).json({
        message: `Lokasi di luar radius kantor (jarak ${Math.round(jarak)}m). Absen ditolak.`,
      });
    }

    const tanggal = hariIni();
    const sudah = await Absensi.findOne({ where: { user_id: req.user.id, tanggal } });
    if (sudah && sudah.jam_masuk) {
      return res.status(400).json({ message: 'Anda sudah absen masuk hari ini' });
    }

    const data = sudah || await Absensi.create({ user_id: req.user.id, tanggal });
    data.jam_masuk = jamSekarang();
    data.foto_masuk = `/uploads/absensi/${req.file.filename}`;
    data.lat_masuk = lat;
    data.lng_masuk = lng;
    await data.save();

    res.json({ message: 'Absen masuk berhasil', data });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// ABSENSI PULANG: ambil foto + validasi GPS
exports.absenPulang = async (req, res) => {
  try {
    const { lat, lng } = req.body;
    if (!lat || !lng) {
      return res.status(400).json({ message: 'Lokasi (lat, lng) wajib dikirim' });
    }
    if (!req.file) {
      return res.status(400).json({ message: 'Foto absen wajib diupload' });
    }

    const { valid, jarak } = isDalamRadiusKantor(parseFloat(lat), parseFloat(lng));
    if (!valid) {
      return res.status(400).json({
        message: `Lokasi di luar radius kantor (jarak ${Math.round(jarak)}m). Absen ditolak.`,
      });
    }

    const tanggal = hariIni();
    const data = await Absensi.findOne({ where: { user_id: req.user.id, tanggal } });
    if (!data || !data.jam_masuk) {
      return res.status(400).json({ message: 'Anda belum absen masuk hari ini' });
    }
    if (data.jam_pulang) {
      return res.status(400).json({ message: 'Anda sudah absen pulang hari ini' });
    }

    data.jam_pulang = jamSekarang();
    data.foto_pulang = `/uploads/absensi/${req.file.filename}`;
    data.lat_pulang = lat;
    data.lng_pulang = lng;
    await data.save();

    res.json({ message: 'Absen pulang berhasil', data });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// status absen hari ini (dipakai HOME screen utk cek "SUDAH ABSEN MASUK?")
exports.statusHariIni = async (req, res) => {
  try {
    const data = await Absensi.findOne({
      where: { user_id: req.user.id, tanggal: hariIni() },
    });
    res.json({
      sudah_absen_masuk: !!(data && data.jam_masuk),
      sudah_absen_pulang: !!(data && data.jam_pulang),
      data: data || null,
    });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// RIWAYAT ABSEN milik karyawan yang login
exports.riwayatSaya = async (req, res) => {
  try {
    const { bulan, tahun } = req.query;
    const where = { user_id: req.user.id };

    if (bulan && tahun) {
      const start = `${tahun}-${String(bulan).padStart(2, '0')}-01`;
      const endDate = new Date(tahun, bulan, 0).getDate();
      const end = `${tahun}-${String(bulan).padStart(2, '0')}-${endDate}`;
      where.tanggal = { [Op.between]: [start, end] };
    }

    const data = await Absensi.findAll({ where, order: [['tanggal', 'DESC']] });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// REKAP ABSENSI untuk admin - semua karyawan
exports.rekapAdmin = async (req, res) => {
  try {
    const { tanggal, user_id, bulan, tahun } = req.query;
    const where = {};
    if (tanggal) where.tanggal = tanggal;
    if (user_id) where.user_id = user_id;

    if (bulan && tahun) {
      const start = `${tahun}-${String(bulan).padStart(2, '0')}-01`;
      const endDate = new Date(tahun, bulan, 0).getDate();
      const end = `${tahun}-${String(bulan).padStart(2, '0')}-${endDate}`;
      where.tanggal = { [Op.between]: [start, end] };
    }

    const data = await Absensi.findAll({
      where,
      include: [{ model: User, attributes: ['id', 'nama', 'email', 'jabatan'] }],
      order: [['tanggal', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};
