import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_service.dart';

class VerifikasiWajahScreen extends StatefulWidget {
  final bool isMasuk;

  const VerifikasiWajahScreen({
    super.key,
    required this.isMasuk,
  });

  @override
  State<VerifikasiWajahScreen> createState() => _VerifikasiWajahScreenState();
}

class _VerifikasiWajahScreenState extends State<VerifikasiWajahScreen> {
  File? _fotoWajah;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    // Secara otomatis dapat mengambil foto dari kamera depan jika belum ada foto
  }

  Future<void> _ambilUlangFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _fotoWajah = File(picked.path));
    }
  }

  Future<void> _lanjutValidasiGps() async {
    setState(() => _loadingGps = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 1. Cek & Minta Izin Lokasi GPS
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingGps = false);
        _tampilkanAlert('Izin Lokasi', 'Izin lokasi (GPS) diperlukan untuk memvalidasi radius kantor.');
        return;
      }

      final isGpsOn = await Geolocator.isLocationServiceEnabled();
      if (!isGpsOn) {
        if (mounted) setState(() => _loadingGps = false);
        _tampilkanAlert('GPS Tidak Aktif', 'Harap aktifkan GPS / Lokasi perangkat terlebih dahulu.');
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

      // 2. Pastikan file foto tersedia, jika belum ambil foto selfie terlebih dahulu
      File fileToUpload;
      if (_fotoWajah != null) {
        fileToUpload = _fotoWajah!;
      } else {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          imageQuality: 80,
        );
        if (picked == null) {
          if (mounted) setState(() => _loadingGps = false);
          return;
        }
        fileToUpload = File(picked.path);
        setState(() => _fotoWajah = fileToUpload);
      }

      // 3. Kirim Absen Masuk / Pulang ke Backend
      final hasil = widget.isMasuk
          ? await ApiService.absenMasuk(
              foto: fileToUpload,
              lat: position.latitude,
              lng: position.longitude,
            )
          : await ApiService.absenPulang(
              foto: fileToUpload,
              lat: position.latitude,
              lng: position.longitude,
            );

      if (!mounted) return;
      setState(() => _loadingGps = false);

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Text(hasil['message'] ?? 'Absensi berhasil diverifikasi!'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _loadingGps = false);
      _tampilkanAlert('Validasi Gagal', e.toString());
    }
  }

  void _tampilkanAlert(String title, String pesan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF27315B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(pesan, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1E2548);
    final isMasuk = widget.isMasuk;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Tombol Back Squircle
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF323B65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Verifikasi Wajah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Status Badge Pill di Kanan Atas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isMasuk ? const Color(0xFFD6DBED) : const Color(0xFF1E432B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isMasuk ? 'Absen Masuk' : 'Absen Pulang',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMasuk ? const Color(0xFF2C355E) : const Color(0xFF4ADE80),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // 2. Frame Pemindaian Wajah (Squircle Ganda Hijau Neon)
              GestureDetector(
                onTap: _ambilUlangFoto,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16324D), Color(0xFF12243C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_fotoWajah != null)
                            Image.file(
                              _fotoWajah!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          // Ikon Lingkaran Centang Hijau di Tengah
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFF43A047),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF1E2548),
                              size: 32,
                              weight: 900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Teks Wajah terverifikasi!
              const Text(
                'Wajah terverifikasi!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Posisikan Wajah Anda di Dalam Frame',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFD1D5DB),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Checklist Status Box (Deteksi Wajah, Verifikasi Identitas, Konfirmasi Hasil)
              _buildChecklistTile('Deteksi Wajah'),
              const SizedBox(height: 12),
              _buildChecklistTile('Verifikasi Identitas'),
              const SizedBox(height: 12),
              _buildChecklistTile('Konfirmasi Hasil'),
              const SizedBox(height: 36),

              // 4. Tombol Aksi: Lanjut Validasi GPS
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43732E), // Warna hijau zaitun pekat sesuai gambar
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _loadingGps ? null : _lanjutValidasiGps,
                  child: _loadingGps
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Lanjut Validasi GPS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistTile(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF27315B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF1E2548),
              size: 18,
              weight: 800,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }
}
