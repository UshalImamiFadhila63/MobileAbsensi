import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import 'laporan_sukses_screen.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _tanggal = DateTime.now();
  final _judulCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController(text: 'Sawah Blok A — Karawang');
  final _unitDroneCtrl = TextEditingController(text: 'DA-001 (DJI Agras T40)');
  final _luasAreaCtrl = TextEditingController(text: '8 Ha');
  final _uraianCtrl = TextEditingController();
  final _hasilCtrl = TextEditingController();
  final _rencanaEsokCtrl = TextEditingController();

  String _jenisKegiatan = 'Penyemprotan Pestisida';
  final List<String> _listJenisKegiatan = [
    'Penyemprotan Pestisida',
    'Survei dan Pemetaan',
    'Pemeliharaan Drone',
    'Penyebaran Pupuk',
    'Operasional Lapangan',
  ];

  bool _submitting = false;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _lokasiCtrl.dispose();
    _unitDroneCtrl.dispose();
    _luasAreaCtrl.dispose();
    _uraianCtrl.dispose();
    _hasilCtrl.dispose();
    _rencanaEsokCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tanggal = picked);
    }
  }

  String _formatTanggalIndo(DateTime dt, {bool withDay = false}) {
    const namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final hari = namaHari[dt.weekday - 1];
    final tgl = dt.day;
    final bulan = namaBulan[dt.month - 1];
    final tahun = dt.year;
    if (withDay) {
      return '$hari, $tgl $bulan $tahun';
    }
    return '$tgl $bulan $tahun';
  }

  Future<void> _kirimLaporan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final tglFormatted = DateFormat('yyyy-MM-dd').format(_tanggal);
      final displayTanggal = _formatTanggalIndo(_tanggal);
      final displayWaktu = DateFormat('HH.mm').format(DateTime.now());

      final judul = _judulCtrl.text.trim();
      final uraian = _uraianCtrl.text.trim();
      final hasil = _hasilCtrl.text.trim().isNotEmpty
          ? _hasilCtrl.text.trim()
          : 'Penyemprotan 100% selesai. Tidak ada kendala signifikan.';
      final rencana = _rencanaEsokCtrl.text.trim().isNotEmpty
          ? _rencanaEsokCtrl.text.trim()
          : 'Melanjutkan operasional sesuai rencana kerja tim.';

      await ApiService.submitLaporan(
        tanggal: tglFormatted,
        judul: judul,
        isiLaporan: uraian,
        jenisKegiatan: _jenisKegiatan,
        lokasi: _lokasiCtrl.text.trim(),
        unitDrone: _unitDroneCtrl.text.trim(),
        luasArea: _luasAreaCtrl.text.trim(),
        uraianPekerjaan: uraian,
        hasil: hasil,
        rencanaEsok: rencana,
      );

      if (!mounted) return;

      // Buka Status Sukses (gantikan BuatLaporanScreen agar tidak menumpuk stack kosong)
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LaporanSuksesScreen(
            tanggal: displayTanggal,
            waktuKirim: displayWaktu,
            status: 'Terkirim',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Gagal mengirim laporan: ${e.toString().replaceAll("Exception:", "").trim()}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR: Tombol Back Bulat + Judul "Buat Laporan Baru"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F5BA8),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Buat Laporan Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 2. KONTEN FORMULIR
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    // KARTU 1: METADATA & OPERASIONAL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INFORMASI OPERASIONAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Tanggal Kegiatan
                          const Text(
                            'Tanggal Kegiatan',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pilihTanggal,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: AppConstants.primaryColor, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    _formatTanggalIndo(_tanggal, withDay: true),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Judul Laporan
                          const Text(
                            'Judul Laporan *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _judulCtrl,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Penyemprotan pestisida Blok A — 8 Ha',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul laporan wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // Jenis Kegiatan
                          const Text(
                            'Jenis Kegiatan',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _listJenisKegiatan.map((item) {
                              final isSelected = _jenisKegiatan == item;
                              return ChoiceChip(
                                label: Text(item),
                                selected: isSelected,
                                selectedColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                                backgroundColor: const Color(0xFFF3F4F6),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppConstants.primaryColor : const Color(0xFF4B5563),
                                ),
                                side: BorderSide(
                                  color: isSelected ? AppConstants.primaryColor : const Color(0xFFE5E7EB),
                                ),
                                onSelected: (sel) {
                                  if (sel) setState(() => _jenisKegiatan = item);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // Lokasi / Area
                          const Text(
                            'Lokasi / Area',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lokasiCtrl,
                            decoration: InputDecoration(
                              hintText: 'Contoh: Sawah Blok A — Karawang',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Unit Drone & Luas Area (2 Kolom)
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Unit Drone',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _unitDroneCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'DA-001 (DJI Agras T40)',
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Luas Area',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _luasAreaCtrl,
                                      decoration: InputDecoration(
                                        hintText: '8 Ha',
                                        filled: true,
                                        fillColor: const Color(0xFFF9FAFB),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KARTU 2: URAIAN PEKERJAAN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'URAIAN PEKERJAAN *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _uraianCtrl,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  'Tuliskan deskripsi lengkap pekerjaan lapangan, jam operasional, dosis semprot / perlakuan, kondisi cuaca, dan SOP...',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5, height: 1.4),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Uraian pekerjaan wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KARTU 3: HASIL & RENCANA ESOK
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HASIL & RENCANA ESOK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Hasil
                          const Text(
                            'Hasil Pekerjaan',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _hasilCtrl,
                            decoration: InputDecoration(
                              hintText: 'Penyemprotan 100% selesai. Tidak ada kendala signifikan.',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Rencana Esok
                          const Text(
                            'Rencana Esok',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _rencanaEsokCtrl,
                            decoration: InputDecoration(
                              hintText: 'Penyemprotan Blok B — 5 Ha dengan drone DA-002.',
                              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. BOTTOM BUTTON: "Kirim Laporan"
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _submitting ? null : _kirimLaporan,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
