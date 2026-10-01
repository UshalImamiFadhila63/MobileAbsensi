import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import 'verifikasi_wajah_screen.dart';
import 'validasi_lokasi_screen.dart';

class AbsensiScreen extends StatefulWidget {
  final bool initialIsMasuk;
  final bool isStandalone;

  const AbsensiScreen({
    super.key,
    this.initialIsMasuk = true,
    this.isStandalone = false,
  });

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  late bool _isMasukSelected;
  late DateTime _currentTime;
  Timer? _timer;

  bool _sudahMasuk = false;
  bool _sudahPulang = false;
  String? _jamMasuk;
  String? _jamPulang;

  @override
  void initState() {
    super.initState();
    _isMasukSelected = widget.initialIsMasuk;
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
    _muatStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _muatStatus() async {
    try {
      final res = await ApiService.statusHariIni();
      if (!mounted) return;
      final data = res['data'];
      setState(() {
        _sudahMasuk = res['sudah_absen_masuk'] ?? false;
        _sudahPulang = res['sudah_absen_pulang'] ?? false;
        if (data != null) {
          _jamMasuk = data['jam_masuk'];
          _jamPulang = data['jam_pulang'];
        }
        // Jika sudah masuk tapi belum pulang, otomatis default tab ke Absen Pulang
        if (_sudahMasuk && !_sudahPulang && widget.initialIsMasuk) {
          _isMasukSelected = false;
        }
      });
    } catch (_) {
      // biarkan tetap menggunakan data lokal jika offline
    }
  }

  String _formatTanggalIndo(DateTime dt) {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final namaHari = hari[dt.weekday - 1];
    final namaBulan = bulan[dt.month - 1];
    return '$namaHari, ${dt.day} $namaBulan ${dt.year}';
  }

  String _formatJamDot(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h.$m.$s';
  }

  Future<void> _mulaiAbsen() async {
    final isMasuk = _isMasukSelected;

    // Validasi apakah sudah absen
    if (isMasuk && _sudahMasuk) {
      _tampilkanAlert('Informasi', 'Anda sudah melakukan absen masuk hari ini.');
      return;
    }
    if (!isMasuk && !_sudahMasuk) {
      _tampilkanAlert('Perhatian', 'Anda belum melakukan absen masuk. Silakan absen masuk terlebih dahulu.');
      return;
    }
    if (!isMasuk && _sudahPulang) {
      _tampilkanAlert('Informasi', 'Anda sudah melakukan absen pulang hari ini.');
      return;
    }

    final sukses = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VerifikasiWajahScreen(isMasuk: isMasuk),
      ),
    );

    if (sukses == true) {
      _muatStatus();
    }
  }

  void _tampilkanAlert(String title, String pesan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Penentuan Badge Status
    String statusTeks = 'Belum Absen';
    Color statusBg = const Color(0xFFFEF3C7);
    Color statusColor = const Color(0xFFD97706);

    if (_sudahMasuk && !_sudahPulang) {
      statusTeks = 'Sudah Masuk';
      statusBg = const Color(0xFFD1FAE5);
      statusColor = const Color(0xFF059669);
    } else if (_sudahPulang) {
      statusTeks = 'Selesai Absen';
      statusBg = const Color(0xFFE0E7FF);
      statusColor = const Color(0xFF4338CA);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.isStandalone
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text(
                'Absensi',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _muatStatus,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Judul Absensi (jika bukan standalone route)
                if (!widget.isStandalone) ...[
                  const Text(
                    'Absensi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 1. KARTU JAM & TANGGAL DIGITAL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTanggalIndo(_currentTime),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatJamDot(_currentTime),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusTeks,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ValidasiLokasiScreen(showBackButton: true),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Color(0xFF374151)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Kantor Pusat',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. KARTU JAM MASUK & JAM PULANG
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Masuk',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _jamMasuk ?? '—',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Pulang',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _jamPulang ?? '—',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. SEGMENTED SWITCHER TAB (ABSEN MASUK / ABSEN PULANG)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isMasukSelected = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isMasukSelected
                                  ? const Color(0xFF4F5BA8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Absen Masuk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isMasukSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isMasukSelected = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isMasukSelected
                                  ? const Color(0xFF4F5BA8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Absen Pulang',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: !_isMasukSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // 4. KARTU FACE RECOGNITION & ACTION BUTTON
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF4F5BA8),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Face Recognition',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Verifikasi wajah + GPS otomatis',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _mulaiAbsen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isMasukSelected
                                ? const Color(0xFF4F5BA8)
                                : const Color(0xFF3F7A38),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.photo_camera, size: 20),
                          label: Text(
                            _isMasukSelected
                                ? 'Mulai Absen Masuk'
                                : 'Mulai Absen Pulang',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pastikan kamera aktif dan GPS menyala',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
