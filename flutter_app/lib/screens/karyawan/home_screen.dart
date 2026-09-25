import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/session.dart';
import 'absen_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  bool _sudahMasuk = false;
  bool _sudahPulang = false;
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final status = await ApiService.statusHariIni();
      final nama = await Session.getNama();
      setState(() {
        _sudahMasuk = status['sudah_absen_masuk'] ?? false;
        _sudahPulang = status['sudah_absen_pulang'] ?? false;
        _nama = nama ?? '';
      });
    } catch (_) {
      // biarkan tampil default kalau gagal ambil status
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _bukaAbsen(bool masuk) async {
    final berhasil = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AbsenScreen(masuk: masuk)),
    );
    if (berhasil == true) _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: RefreshIndicator(
        onRefresh: _muat,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Halo, $_nama 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Semoga harimu produktif!', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _KartuAbsen(
                          judul: 'Absen Masuk',
                          icon: Icons.login,
                          sudah: _sudahMasuk,
                          aktif: !_sudahMasuk,
                          onTap: () => _bukaAbsen(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KartuAbsen(
                          judul: 'Absen Pulang',
                          icon: Icons.logout,
                          sudah: _sudahPulang,
                          aktif: _sudahMasuk && !_sudahPulang,
                          onTap: () => _bukaAbsen(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _KartuAbsen extends StatelessWidget {
  final String judul;
  final IconData icon;
  final bool sudah;
  final bool aktif;
  final VoidCallback onTap;

  const _KartuAbsen({
    required this.judul,
    required this.icon,
    required this.sudah,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: aktif ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 36, color: sudah ? Colors.green : (aktif ? Colors.indigo : Colors.grey)),
              const SizedBox(height: 12),
              Text(judul, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                sudah ? 'Sudah absen' : (aktif ? 'Ketuk untuk absen' : 'Belum bisa'),
                style: TextStyle(fontSize: 12, color: sudah ? Colors.green : Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
