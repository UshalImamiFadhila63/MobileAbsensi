import 'package:flutter/material.dart';
import '../core/session.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingItem {
  final IconData icon;
  final String judul;
  final String deskripsi;
  const _OnboardingItem(this.icon, this.judul, this.deskripsi);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _halaman = 0;

  final _items = const [
    _OnboardingItem(
      Icons.camera_alt,
      'Absen dengan Foto & Lokasi',
      'Absen masuk dan pulang cukup dengan foto selfie dan validasi lokasi GPS.',
    ),
    _OnboardingItem(
      Icons.event_available,
      'Pengajuan Cuti Mudah',
      'Ajukan cuti langsung dari aplikasi dan pantau status persetujuannya.',
    ),
    _OnboardingItem(
      Icons.description,
      'Laporan & Riwayat',
      'Kirim laporan harian dan lihat riwayat absensi kapan saja.',
    ),
  ];

  Future<void> _selesai() async {
    await Session.tandaiOnboardingSelesai();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _selesai,
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _halaman = i),
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 100, color: Colors.indigo),
                        const SizedBox(height: 32),
                        Text(item.judul,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(item.deskripsi,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 15, color: Colors.black54)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, (i) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _halaman ? Colors.indigo : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
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
                  child: Text(_halaman == _items.length - 1 ? 'Mulai' : 'Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
