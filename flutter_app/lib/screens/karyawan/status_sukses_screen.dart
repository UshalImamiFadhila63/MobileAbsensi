import 'package:flutter/material.dart';
import '../../core/session.dart';
import 'dashboard_karyawan.dart';

/// Halaman Status Sukses / Berhasil Karyawan
/// Mendukung 2 Tampilan persis 100% sesuai screenshot Figma:
/// 1. Tampilan "Absen Pulang Berhasil!" / "Absen Masuk Berhasil!"
/// 2. Tampilan "Laporan Terkirim!"
class StatusSuksesScreen extends StatefulWidget {
  final bool isLaporan; // true jika untuk laporan, false jika untuk absensi
  final bool isMasuk; // true jika absen masuk, false jika absen pulang
  final String? nama;
  final String? waktu;
  final String? tanggal;
  final String? status;
  final String? lokasi;
  final VoidCallback? onKembali;

  const StatusSuksesScreen({
    super.key,
    this.isLaporan = false,
    this.isMasuk = false,
    this.nama,
    this.waktu,
    this.tanggal,
    this.status,
    this.lokasi,
    this.onKembali,
  });

  /// Factory untuk Absen Berhasil (Default Absen Pulang seperti Gambar 1)
  factory StatusSuksesScreen.absen({
    bool isMasuk = false,
    String? nama,
    String? waktu,
    String? tanggal,
    String? status,
    String? lokasi,
    VoidCallback? onKembali,
  }) {
    return StatusSuksesScreen(
      isLaporan: false,
      isMasuk: isMasuk,
      nama: nama,
      waktu: waktu,
      tanggal: tanggal,
      status: status,
      lokasi: lokasi,
      onKembali: onKembali,
    );
  }

  /// Factory untuk Laporan Terkirim (Persis Gambar 2)
  factory StatusSuksesScreen.laporan({
    String? tanggal,
    String? waktuKirim,
    String? status,
    VoidCallback? onKembali,
  }) {
    return StatusSuksesScreen(
      isLaporan: true,
      tanggal: tanggal,
      waktu: waktuKirim,
      status: status,
      onKembali: onKembali,
    );
  }

  @override
  State<StatusSuksesScreen> createState() => _StatusSuksesScreenState();
}

class _StatusSuksesScreenState extends State<StatusSuksesScreen> {
  String _namaDisplay = 'Ahmad Fauzi';

  static const List<String> _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _loadNama();
  }

  Future<void> _loadNama() async {
    if (widget.nama != null && widget.nama!.isNotEmpty) {
      setState(() => _namaDisplay = widget.nama!);
      return;
    }
    final saved = await Session.getNama();
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _namaDisplay = saved);
    }
  }

  String _formatTanggalDefault(int defaultDay) {
    if (widget.tanggal != null && widget.tanggal!.isNotEmpty) {
      return widget.tanggal!;
    }
    final now = DateTime.now();
    return '$defaultDay ${_namaBulan[now.month]} ${now.year}';
  }

  String _formatWaktuDefault(String defaultTime) {
    if (widget.waktu != null && widget.waktu!.isNotEmpty) {
      return widget.waktu!;
    }
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  void _kembaliKeDashboard() {
    if (widget.onKembali != null) {
      try {
        widget.onKembali!();
        return;
      } catch (e) {
        debugPrint('[StatusSuksesScreen] error onKembali: $e');
      }
    }
    if (!mounted) return;
    // Kembali ke dashboard utama
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardKaryawan(initialIndex: widget.isLaporan ? 3 : 0),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _kembaliKeDashboard();
      },
      child: widget.isLaporan
          ? _buildLaporanSukses(context)
          : _buildAbsenSukses(context),
    );
  }

  // ==========================================
  // 1. TAMPILAN: ABSEN BERHASIL (Gambar 1)
  // ==========================================
  Widget _buildAbsenSukses(BuildContext context) {
    final String title = widget.isMasuk ? 'Absen Masuk Berhasil!' : 'Absen Pulang Berhasil!';
    final String waktuVal = _formatWaktuDefault('15.53');
    final String tanggalVal = _formatTanggalDefault(28);
    final String statusVal = widget.status ?? (widget.isMasuk ? 'Sudah Masuk' : 'Sudah Pulang');
    final String lokasiVal = widget.lokasi ?? 'Kantor Pusat';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Divider halus paling atas persis screenshot
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),

                    // LINGKARAN IKON CENTANG HIJAU
                    // Outer circle: #BAE7B4, Inner circle: #48742C
                    _buildCheckmarkIcon(),

                    const SizedBox(height: 24),

                    // JUDUL UTAMA
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // SUBTITLE
                    const Text(
                      'Absensi Anda telah tercatat dalam sistem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // KARTU TABEL DETAIL ABSENSI
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTableRow('Nama', _namaDisplay),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow('Waktu', waktuVal),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow('Tanggal', tanggalVal),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow(
                            'Status',
                            statusVal,
                            valueColor: statusVal.toLowerCase().contains('terlambat')
                                ? const Color(0xFFEA580C)
                                : (statusVal.toLowerCase().contains('awal') || statusVal.toLowerCase().contains('tepat')
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF111827)),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow('Lokasi', lokasiVal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL: "Kembali ke Dashboard"
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. TAMPILAN: LAPORAN TERKIRIM (Gambar 2)
  // ==========================================
  Widget _buildLaporanSukses(BuildContext context) {
    final String waktuVal = _formatWaktuDefault('08.42');
    final String tanggalVal = _formatTanggalDefault(30);
    final String statusVal = widget.status ?? 'Terkirim';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Divider halus paling atas persis screenshot
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),

                    // LINGKARAN IKON CENTANG HIJAU
                    _buildCheckmarkIcon(),

                    const SizedBox(height: 24),

                    // JUDUL UTAMA
                    const Text(
                      'Laporan Terkirim!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // SUBTITLE (2 baris sesuai mockup)
                    const Text(
                      'Laporan harian Anda telah berhasil dikirim\ndan tersimpan dalam sistem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // KARTU TABEL DETAIL LAPORAN
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTableRow('Tanggal', tanggalVal),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow('Waktu Kirim', waktuVal),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                          _buildTableRow('Status', statusVal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL: "Kembali ke Dashboard"
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Lingkaran Centang Hijau
  Widget _buildCheckmarkIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFBAE7B4), // Lingkaran luar hijau pastel
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFF48742C), // Lingkaran dalam hijau zaitun pekat
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // WIDGET HELPER: Baris Tabel Detail
  Widget _buildTableRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Tombol "Kembali ke Dashboard"
  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F5BA8), // Warna biru-keunguan utama
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _kembaliKeDashboard,
          child: const Text(
            'Kembali ke Dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alias kelas agar mudah dipanggil sesuai kebutuhan:
class AbsenSuksesScreen extends StatelessWidget {
  final bool isMasuk;
  final String? nama;
  final String? waktu;
  final String? tanggal;
  final String? status;
  final String? lokasi;

  const AbsenSuksesScreen({
    super.key,
    this.isMasuk = false,
    this.nama,
    this.waktu,
    this.tanggal,
    this.status,
    this.lokasi,
  });

  @override
  Widget build(BuildContext context) {
    return StatusSuksesScreen.absen(
      isMasuk: isMasuk,
      nama: nama,
      waktu: waktu,
      tanggal: tanggal,
      status: status,
      lokasi: lokasi,
    );
  }
}

class LaporanSuksesScreen extends StatelessWidget {
  final String? tanggal;
  final String? waktuKirim;
  final String? status;
  final VoidCallback? onKembali;

  const LaporanSuksesScreen({
    super.key,
    this.tanggal,
    this.waktuKirim,
    this.status,
    this.onKembali,
  });

  @override
  Widget build(BuildContext context) {
    return StatusSuksesScreen.laporan(
      tanggal: tanggal,
      waktuKirim: waktuKirim,
      status: status,
      onKembali: onKembali,
    );
  }
}
