const Cuti = require('../models/Cuti');
const User = require('../models/User');
const notifikasiController = require('./notifikasiController');

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

    // Buat notifikasi untuk karyawan sendiri
    await notifikasiController.buatNotifikasi({
      user_id: req.user.id,
      tipe: 'cuti',
      judul: 'Pengajuan Cuti Terkirim',
      pesan: `Pengajuan ${jenis_cuti} (${tanggal_mulai} s/d ${tanggal_selesai}) berhasil dikirim dan menunggu persetujuan admin.`,
      cta_text: 'Lihat Status Cuti →',
      data: { cuti_id: cuti.id, tabIndex: 1 },
    });

    // Buat notifikasi untuk semua admin
    try {
      const admins = await User.findAll({ where: { role: 'admin' } });
      const pemohon = await User.findByPk(req.user.id);
      for (const admin of admins) {
        await notifikasiController.buatNotifikasi({
          user_id: admin.id,
          tipe: 'cuti',
          judul: 'Pengajuan Cuti Baru',
          pesan: `${pemohon ? pemohon.nama : 'Karyawan'} mengajukan cuti ${jenis_cuti} (${tanggal_mulai} s/d ${tanggal_selesai}).`,
          cta_text: 'Tinjau Pengajuan Cuti →',
          data: { cuti_id: cuti.id },
        });
      }
    } catch (_) {}

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

    // Kirim notifikasi hasil verifikasi ke karyawan pemohon
    const isAcc = status === 'diterima';
    await notifikasiController.buatNotifikasi({
      user_id: cuti.user_id,
      tipe: 'cuti',
      judul: isAcc ? 'Pengajuan Cuti Disetujui' : 'Pengajuan Cuti Ditolak',
      pesan: isAcc
        ? `Pengajuan cuti ${cuti.jenis_cuti} (${cuti.tanggal_mulai} s/d ${cuti.tanggal_selesai}) telah disetujui admin.`
        : `Pengajuan cuti ${cuti.jenis_cuti} (${cuti.tanggal_mulai} s/d ${cuti.tanggal_selesai}) ditolak. Alasan: ${catatan_admin || 'Tidak ada catatan.'}`,
      cta_text: 'Lihat Status & Riwayat Cuti →',
      data: { cuti_id: cuti.id, tabIndex: 1 },
    });

    res.json({ message: `Pengajuan cuti telah ${status}`, data: cuti });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};
