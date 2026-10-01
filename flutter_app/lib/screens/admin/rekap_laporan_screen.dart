import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import 'components/notifikasi_sheet.dart';

class RekapLaporanScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenNotifikasi;
  final VoidCallback? onBukaProfil;

  const RekapLaporanScreen({
    super.key,
    this.showAppBar = false,
    this.onOpenDrawer,
    this.onOpenNotifikasi,
    this.onBukaProfil,
  });

  @override
  State<RekapLaporanScreen> createState() => _RekapLaporanScreenState();
}

class _RekapLaporanScreenState extends State<RekapLaporanScreen> {
  late Future<List<dynamic>> _future;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // Data default persis sesuai mockup gambar yang dikirimkan user
  final List<Map<String, dynamic>> _mockLaporan = [
    {
      'id': 1,
      'nama': 'Lilit\nRansink',
      'initials': 'LR',
      'avatarColor': const Color(0xFF2F6B64),
      'tanggal': '18 Agustus\n2026',
      'judul': 'Laporan Shift Pagi',
      'isi': 'Semua target operasional shift pagi berjalan optimal sesuai SOP.',
    },
    {
      'id': 2,
      'nama': 'Ransink\nLilit',
      'initials': 'RS',
      'avatarColor': const Color(0xFF385C83),
      'tanggal': '18 Agustus\n2026',
      'judul': 'Laporan Pemasaran',
      'isi': 'Analisis campaign kuartal ketiga menunjukkan pertumbuhan impresi 18%.',
    },
    {
      'id': 3,
      'nama': 'Udin\nKomarudin',
      'initials': 'UK',
      'avatarColor': const Color(0xFF2F6B64),
      'tanggal': '18 Agustus\n2026',
      'judul': 'Maintenance Server',
      'isi': 'Pembaruan paket keamanan server internal selesai tanpa downtime.',
    },
    {
      'id': 4,
      'nama': 'Alak\nBizher',
      'initials': 'AB',
      'avatarColor': const Color(0xFF385C83),
      'tanggal': '18 Agustus\n2026',
      'judul': 'Pemeriksaan Logistik',
      'isi': 'Stok barang masuk dan keluar telah diverifikasi sesuai manifes.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _muat() {
    setState(() {
      _future = ApiService.rekapLaporan();
    });
  }

  Future<void> _bukaNotifikasi() async {
    if (widget.onOpenNotifikasi != null) {
      widget.onOpenNotifikasi!();
      return;
    }
    await NotifikasiSheet.show(
      context,
      jumlahCutiMenunggu: 3,
      jumlahBelumAbsen: 5,
      jumlahTerlambat: 2,
    );
  }

  void _lihatDetailLaporan(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          item['judul'] ?? 'Detail Laporan',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Color(0xFF4F5BA8)),
                const SizedBox(width: 6),
                Text(
                  (item['nama'] ?? '').toString().replaceAll('\n', ' '),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(
                  (item['tanggal'] ?? '').toString().replaceAll('\n', ' '),
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              item['isi'] ?? '-',
              style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF374151)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF4F5BA8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _muat(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. FLOATING TOP BAR PERSIS GAMBAR MOCKUP
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hamburger + Judul Rekap Laporan
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              size: 26,
                              color: Color(0xFF111827),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: widget.onOpenDrawer,
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Rekap Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),

                      // Bell Notifikasi & Avatar "SA"
                      Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_rounded,
                                  size: 24,
                                  color: Color(0xFF111827),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _bukaNotifikasi,
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: widget.onBukaProfil,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF488286), // Teal SA
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'SA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. KOTAK SEARCH "Cari nama karyawan..." PERSIS GAMBAR
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                      hintText: 'Cari nama karyawan...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. DUA KARTU METRIK VERTIKAL (Laporan Masuk & Total Karyawan)
                FutureBuilder<List<dynamic>>(
                  future: _future,
                  builder: (context, snap) {
                    List<Map<String, dynamic>> items;

                    if (snap.hasData && snap.data!.isNotEmpty) {
                      items = snap.data!.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = Map<String, dynamic>.from(entry.value);
                        final user = m['User'] ?? {};
                        final rawNama = (user['nama'] ?? m['nama'] ?? 'Karyawan').toString();
                        final parts = rawNama.trim().split(RegExp(r'\s+'));
                        final initials = parts.length >= 2
                            ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
                            : rawNama.toUpperCase();
                        final formattedNama = parts.length >= 2
                            ? '${parts[0]}\n${parts.sublist(1).join(' ')}'
                            : rawNama;

                        final rawTgl = (m['tanggal'] ?? m['createdAt'] ?? '18 Agustus 2026').toString();
                        final formattedTgl = rawTgl.contains(' ')
                            ? rawTgl.replaceFirst(' ', '\n')
                            : rawTgl;

                        return {
                          'id': m['id'] ?? (i + 1),
                          'nama': formattedNama,
                          'initials': initials,
                          'avatarColor': i.isEven ? const Color(0xFF2F6B64) : const Color(0xFF385C83),
                          'tanggal': formattedTgl,
                          'judul': m['judul'] ?? 'Laporan Kegiatan',
                          'isi': m['isi_laporan'] ?? '-',
                        };
                      }).toList();
                    } else {
                      items = _mockLaporan;
                    }

                    int totalLaporan = items.length;
                    int totalKaryawan = 20; // Sesuai mockup gambar

                    if (items == _mockLaporan) {
                      totalLaporan = 15;
                      totalKaryawan = 20;
                    }

                    final filtered = items.where((k) {
                      if (_query.isEmpty) return true;
                      final nama = (k['nama'] ?? '').toString().toLowerCase();
                      final judul = (k['judul'] ?? '').toString().toLowerCase();
                      return nama.contains(_query) || judul.contains(_query);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kartu 1: Laporan Masuk
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD1D5DB).withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Laporan Masuk',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalLaporan',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Kartu 2: Total Karyawan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD1D5DB).withValues(alpha: 0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Karyawan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$totalKaryawan',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 4. TABEL REKAP LAPORAN PERSIS GAMBAR
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Kolom: NAMA & TANGGAL (Tanpa garis divider)
                              const Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'NAMA',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF6B7280),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'TANGGAL',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF6B7280),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Daftar Baris Laporan
                              if (filtered.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'Laporan tidak ditemukan',
                                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 22),
                                  itemBuilder: (context, i) {
                                    final item = filtered[i];
                                    final nama = item['nama'] as String;
                                    final initials = item['initials'] as String;
                                    final avatarColor = (item['avatarColor'] as Color?) ?? const Color(0xFF2F6B64);
                                    final tanggal = item['tanggal'] as String;

                                    return InkWell(
                                      onTap: () => _lihatDetailLaporan(item),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Kolom NAMA (Avatar + Nama 2 baris)
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor: avatarColor,
                                                  child: Text(
                                                    initials,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    nama,
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF111827),
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Kolom TANGGAL (2 baris)
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              tanggal,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4B5563),
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
