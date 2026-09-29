import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';

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

  bool _processing = false;

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

    setState(() => _processing = true);

    try {
      // 1. Ambil Lokasi GPS
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() => _processing = false);
        _tampilkanAlert('Izin Lokasi', 'Izin lokasi (GPS) diperlukan untuk validasi kehadiran.');
        return;
      }

      final isGpsOn = await Geolocator.isLocationServiceEnabled();
      if (!isGpsOn) {
        setState(() => _processing = false);
        _tampilkanAlert('GPS Tidak Aktif', 'Harap aktifkan GPS / Lokasi perangkat Anda terlebih dahulu.');
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition() ??
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
            );
      }

      // 2. Ambil Foto Kamera Depan (Face Recognition)
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (picked == null) {
        setState(() => _processing = false);
        return; // Dibatalkan oleh pengguna
      }

      final fotoFile = File(picked.path);

      // 3. Konfirmasi / Submit ke Backend
      if (!mounted) return;
      _konfirmasiDanKirim(fotoFile, position, isMasuk);
    } catch (e) {
      setState(() => _processing = false);
      _tampilkanAlert('Kesalahan', 'Gagal memproses absensi: $e');
    }
  }

  void _konfirmasiDanKirim(File foto, Position position, bool isMasuk) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool sending = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isMasuk ? 'Konfirmasi Absen Masuk' : 'Konfirmasi Absen Pulang'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      foto,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'GPS: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                        ),
                      ),
                    ],
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!sending)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _processing = false);
                  },
                  child: const Text('Batal'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMasuk ? AppConstants.primaryColor : const Color(0xFF3F7A38),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: sending
                    ? null
                    : () async {
                        setDialogState(() {
                          sending = true;
                          dialogError = null;
                        });

                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final hasil = isMasuk
                              ? await ApiService.absenMasuk(
                                  foto: foto,
                                  lat: position.latitude,
                                  lng: position.longitude,
                                )
                              : await ApiService.absenPulang(
                                  foto: foto,
                                  lat: position.latitude,
                                  lng: position.longitude,
                                );

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (mounted) setState(() => _processing = false);

                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green.shade700,
                              content: Text(hasil['message'] ?? 'Absen berhasil!'),
                            ),
                          );

                          // Muat ulang status hari ini
                          await _muatStatus();
                        } catch (err) {
                          setDialogState(() {
                            sending = false;
                            dialogError = err.toString();
                          });
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Kirim Absensi'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) setState(() => _processing = false);
    });
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Kantor Pusat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
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
                          onPressed: _processing ? null : _mulaiAbsen,
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
                          icon: _processing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.photo_camera, size: 20),
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
