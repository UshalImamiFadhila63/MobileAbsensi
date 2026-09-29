import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final String imagePath;
  final String judul;
  final String deskripsi;
  const _OnboardingItem({
    required this.imagePath,
    required this.judul,
    required this.deskripsi,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _halaman = 0;

  final _items = const [
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_camera.png',
      judul: 'Absensi Cepat & Akurat',
      deskripsi:
          'Absen masuk dan pulang cukup dengan foto selfie dan validasi lokasi GPS akurat di area kantor.',
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_shield.png',
      judul: 'Verifikasi Wajah Aman',
      deskripsi:
          'Face recognition memastikan absensi dilakukan oleh karyawan yang bersangkutan — akurat dan anti-titip absen.',
    ),
    _OnboardingItem(
      imagePath: 'assets/images/onboarding_document.png',
      judul: 'Pengajuan & Rekap Mudah',
      deskripsi:
          'Ajukan cuti kerja dan pantau riwayat kehadiran harian dengan mudah langsung dari aplikasi.',
    ),
  ];

  void _selesai() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Slider Konten
            Expanded(
              flex: 8,
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _halaman = i),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Card dari Gambar Asli
                        Image.asset(
                          item.imagePath,
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 38),
                        // Judul
                        Text(
                          item.judul,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Deskripsi
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            item.deskripsi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Indikator Dots / Capsule Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (i) {
                final bool isActive = i == _halaman;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 34 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppConstants.primaryColor
                        : const Color(0xFFD6D8E1),
                    borderRadius: BorderRadius.circular(isActive ? 6 : 5),
                  ),
                );
              }),
            ),
            const Spacer(flex: 2),
            // Tombol Navigasi Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_halaman == _items.length - 1) {
                          _selesai();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _halaman == _items.length - 1 ? 'Mulai' : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _selesai,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

