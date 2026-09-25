const Cuti = require('../models/Cuti');
const User = require('../models/User');

// ISI FORMULIR CUTI -> AJUKAN CUTI
exports.ajukanCuti = async (req, res) => {
  try {
    const { jenis_cuti, tanggal_mulai, tanggal_selesai, alasan } = req.body;

    if (!jenis_cuti || !tanggal_mulai || !tanggal_selesai || !alasan) {
      return res.status(400).json({ message: 'Semua field formulir cuti wajib diisi' });
    }

    const cuti = await Cuti.create({
      user_id: req.user.id,
      jenis_cuti,
      tanggal_mulai,
      tanggal_selesai,
      alasan,
      lampiran: req.file ? `/uploads/cuti/${req.file.filename}` : null,
      status: 'menunggu',
    });

    res.status(201).json({ message: 'Pengajuan cuti berhasil dikirim, menunggu persetujuan admin', data: cuti });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// INFORMASI CUTI (riwayat pengajuan cuti tercatat) - karyawan yang login
exports.informasiCutiSaya = async (req, res) => {
  try {
    const data = await Cuti.findAll({
      where: { user_id: req.user.id },
      order: [['createdAt', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// LIHAT DAFTAR PENGAJUAN (admin) - default hanya yang menunggu, bisa filter status
exports.daftarPengajuan = async (req, res) => {
  try {
    const { status } = req.query;
    const where = status ? { status } : {};
    const data = await Cuti.findAll({
      where,
      include: [{ model: User, attributes: ['id', 'nama', 'email', 'jabatan'] }],
      order: [['createdAt', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// PERIKSA DETAIL DAN LAMPIRAN PENGAJUAN
exports.detailPengajuan = async (req, res) => {
  try {
    const data = await Cuti.findByPk(req.params.id, {
      include: [{ model: User, attributes: ['id', 'nama', 'email', 'jabatan'] }],
    });
    if (!data) return res.status(404).json({ message: 'Pengajuan tidak ditemukan' });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// SETUJUI CUTI? -> update status diterima / ditolak (dan tetap update status pengajuan)
exports.prosesPengajuan = async (req, res) => {
  try {
    const { status, catatan_admin } = req.body; // status: 'diterima' | 'ditolak'
    if (!['diterima', 'ditolak'].includes(status)) {
      return res.status(400).json({ message: "status harus 'diterima' atau 'ditolak'" });
    }

    const cuti = await Cuti.findByPk(req.params.id);
    if (!cuti) return res.status(404).json({ message: 'Pengajuan tidak ditemukan' });

    cuti.status = status;
    cuti.catatan_admin = catatan_admin || null;
    cuti.diproses_oleh = req.user.id;
    await cuti.save();

    res.json({ message: `Pengajuan cuti telah ${status}`, data: cuti });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};
