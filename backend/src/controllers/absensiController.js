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

    const jam = jamSekarang();
    // Patokan jam masuk 08:00 WIB: jika lewat 08:00:00 dianggap telat
    const isTelat = jam > '08:00:00';
    const status = isTelat ? 'telat' : 'hadir';

    const data = sudah || await Absensi.create({ user_id: req.user.id, tanggal });
    data.jam_masuk = jam;
    data.foto_masuk = `/uploads/absensi/${req.file.filename}`;
    data.lat_masuk = lat;
    data.lng_masuk = lng;
    data.status = status;
    await data.save();

    res.json({ message: 'Absen masuk berhasil', data });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// ABSENSI PULANG: ambil foto + validasi GPS + validasi jam >= 17:00
exports.absenPulang = async (req, res) => {
  try {
    const { lat, lng } = req.body;
    if (!lat || !lng) {
      return res.status(400).json({ message: 'Lokasi (lat, lng) wajib dikirim' });
    }
    if (!req.file) {
      return res.status(400).json({ message: 'Foto absen wajib diupload' });
    }

    // Validasi jam: absen pulang hanya boleh mulai pukul 17:00 WIB
    const jam = jamSekarang(); // HH:MM:SS
    if (jam < '17:00:00') {
      const sisaMenit = Math.ceil(
        (new Date(`1970-01-01T17:00:00`) - new Date(`1970-01-01T${jam}`)) / 60000
      );
      return res.status(400).json({
        message: `Absen pulang hanya bisa dilakukan mulai pukul 17:00 WIB. Sisa waktu: ${sisaMenit} menit lagi.`,
      });
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

    data.jam_pulang = jam;
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

    const data = await Absensi.findAll({
      where,
      include: [{ model: User, attributes: ['id', 'nama', 'email', 'jabatan', 'foto_profil'] }],
      order: [['tanggal', 'DESC'], ['id', 'DESC']],
    });
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
      include: [{ model: User, attributes: ['id', 'nama', 'email', 'jabatan', 'foto_profil'] }],
      order: [['tanggal', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};
