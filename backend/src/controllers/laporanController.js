const Laporan = require('../models/Laporan');
const User = require('../models/User');

// FORM LAPORAN -> SUBMIT
exports.submitLaporan = async (req, res) => {
  try {
    const {
      tanggal,
      judul,
      isi_laporan,
      jenis_kegiatan,
      lokasi,
      unit_drone,
      luas_area,
      uraian_pekerjaan,
      hasil,
      rencana_esok,
      status,
    } = req.body;

    if (!tanggal || !judul) {
      return res.status(400).json({ message: 'Tanggal dan judul laporan wajib diisi' });
    }

    const isi = (isi_laporan || uraian_pekerjaan || '').trim() || 'Laporan kegiatan telah dicatat.';

    const laporan = await Laporan.create({
      user_id: req.user.id,
      tanggal,
      judul,
      isi_laporan: isi,
      jenis_kegiatan: jenis_kegiatan || judul,
      lokasi: lokasi || 'Sawah Blok A — Karawang',
      unit_drone: unit_drone || 'DA-001 (DJI Agras T40)',
      luas_area: luas_area || '8 Ha',
      uraian_pekerjaan: uraian_pekerjaan || isi,
      hasil: hasil || 'Penyemprotan 100% selesai. Tidak ada kendala signifikan.',
      rencana_esok: rencana_esok || 'Melanjutkan operasional sesuai jadwal.',
      status: status || 'Terkirim',
      lampiran: req.file ? `/uploads/laporan/${req.file.filename}` : null,
    });

    res.status(201).json({ message: 'Laporan berhasil dikirim', data: laporan });
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

exports.laporanSaya = async (req, res) => {
  try {
    const data = await Laporan.findAll({
      where: { user_id: req.user.id },
      order: [['tanggal', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};

// REKAP LAPORAN untuk admin
exports.rekapLaporan = async (req, res) => {
  try {
    const data = await Laporan.findAll({
      include: [{ model: User, attributes: ['id', 'nama', 'jabatan'] }],
      order: [['tanggal', 'DESC']],
    });
    res.json(data);
  } catch (err) {
    res.status(500).json({ message: 'Terjadi kesalahan server', error: err.message });
  }
};
