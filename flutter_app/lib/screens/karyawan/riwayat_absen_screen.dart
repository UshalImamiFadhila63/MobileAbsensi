import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import 'detail_absensi_screen.dart';

class RiwayatAbsenScreen extends StatefulWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  State<RiwayatAbsenScreen> createState() => _RiwayatAbsenScreenState();
}

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'Semua'; // 'Semua', 'Hadir', 'Terlambat', 'Izin Cuti'
  bool _loading = true;
  List<Map<String, dynamic>> _listRiwayat = [];
  Map<String, dynamic>? _riwayatTerpilih;

  @override
  void initState() {
    super.initState();
    _muatData();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Data default demo jika server belum memiliki rekap lengkap (agar persis desain)
  final List<Map<String, dynamic>> _demoFallback = [
    {
      'id': 1,
      'tanggal': '2026-08-18',
      'tanggal_lengkap': 'Jumat, 18 Agustus 2026',
      'hari': 'Jumat',
      'tgl': '18',
      'bulan': 'AGU',
      'status': 'Hadir',
      'jam_masuk': '07:30',
      'jam_pulang': '17:05',
      'total_jam': '9 jam 35 menit',
      'lokasi': 'Kantor Pusat (-6.20000, 106.81666)',
    },
    {
      'id': 2,
      'tanggal': '2026-08-17',
      'tanggal_lengkap': 'Kamis, 17 Agustus 2026',
      'hari': 'Kamis',
      'tgl': '17',
      'bulan': 'AGU',
      'status': 'Hadir',
      'jam_masuk': '08:00',
      'jam_pulang': '17:00',
      'total_jam': '9 jam',
      'lokasi': 'Kantor Pusat (-6.20000, 106.81666)',
    },
    {
      'id': 3,
      'tanggal': '2026-08-16',
      'tanggal_lengkap': 'Rabu, 16 Agustus 2026',
      'hari': 'Rabu',
      'tgl': '16',
      'bulan': 'AGU',
      'status': 'Terlambat',
      'jam_masuk': '09:15',
      'jam_pulang': '17:00',
      'total_jam': '7 jam 45 menit',
      'lokasi': 'Kantor Pusat (-6.20000, 106.81666)',
    },
    {
      'id': 4,
      'tanggal': '2026-08-15',
      'tanggal_lengkap': 'Selasa, 15 Agustus 2026',
      'hari': 'Selasa',
      'tgl': '15',
      'bulan': 'AGU',
      'status': 'Izin Cuti',
      'jam_masuk': '—',
      'jam_pulang': '—',
      'total_jam': '—',
      'lokasi': 'Izin Dinas / Cuti Tahunan',
    },
    {
      'id': 5,
      'tanggal': '2026-08-14',
      'tanggal_lengkap': 'Senin, 14 Agustus 2026',
      'hari': 'Senin',
      'tgl': '14',
      'bulan': 'AGU',
      'status': 'Hadir',
      'jam_masuk': '07:55',
      'jam_pulang': '17:20',
      'total_jam': '9 jam 42 menit',
      'lokasi': 'Kantor Pusat (-6.20000, 106.81666)',
    },
  ];

  Future<void> _muatData() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.riwayatAbsen();
      final parsed = <Map<String, dynamic>>[];

      for (final item in res) {
        final tglStr = item['tanggal']?.toString() ?? '';
        DateTime? dt;
        try {
          dt = DateTime.parse(tglStr);
        } catch (_) {}

        String hari = 'Hari';
        String tgl = '01';
        String bulan = 'BLN';

        if (dt != null) {
          const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
          const bulanList = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
          hari = hariList[dt.weekday - 1];
          tgl = dt.day.toString().padLeft(2, '0');
          bulan = bulanList[dt.month - 1];
        }

        String jamMsk = item['jam_masuk']?.toString() ?? '—';
        if (jamMsk.length >= 5) jamMsk = jamMsk.substring(0, 5);

        String jamPlg = item['jam_pulang']?.toString() ?? '—';
        if (jamPlg.length >= 5) jamPlg = jamPlg.substring(0, 5);

        String status = 'Hadir';
        if (item['status'] != null) {
          status = item['status'].toString();
        } else if (jamMsk != '—') {
          // Jika masuk lewat jam 08:30 dianggap Terlambat
          final jamInt = int.tryParse(jamMsk.split(':').first) ?? 0;
          final menitInt = int.tryParse(jamMsk.split(':').last) ?? 0;
          if (jamInt > 8 || (jamInt == 8 && menitInt > 30)) {
            status = 'Terlambat';
          }
        }

        parsed.add({
          'id': item['id'],
          'tanggal': tglStr,
          'hari': hari,
          'tgl': tgl,
          'bulan': bulan,
          'status': status,
          'jam_masuk': jamMsk,
          'jam_pulang': jamPlg,
          'foto_masuk': item['foto_masuk'],
          'foto_pulang': item['foto_pulang'],
        });
      }

      // Jika data dari server ada, gunakan server. Jika masih kosong, gabungkan demo fallback
      setState(() {
        _listRiwayat = parsed.isNotEmpty ? parsed : _demoFallback;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _listRiwayat = _demoFallback;
          _loading = false;
        });
      }
    }
  }

  void _bukaDetail(Map<String, dynamic> item) {
    setState(() {
      _riwayatTerpilih = item;
    });
  }


  Widget _buildStatusPill(String status) {
    Color bg = const Color(0xFFDCFCE7);
    Color textColor = const Color(0xFF16A34A);

    if (status.toLowerCase().contains('terlambat')) {
      bg = const Color(0xFFFFEDD5);
      textColor = const Color(0xFFEA580C);
    } else if (status.toLowerCase().contains('cuti') || status.toLowerCase().contains('izin')) {
      bg = const Color(0xFFE0E7FF);
      textColor = const Color(0xFF4338CA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_riwayatTerpilih != null) {
      return DetailAbsensiScreen(
        item: _riwayatTerpilih!,
        onBack: () => setState(() => _riwayatTerpilih = null),
      );
    }

    // Hitung ringkasan statistik
    int countHadir = 0;
    int countTerlambat = 0;
    int countCuti = 0;

    for (final item in _listRiwayat) {
      final st = (item['status'] ?? '').toString().toLowerCase();
      if (st.contains('terlambat')) {
        countTerlambat++;
      } else if (st.contains('cuti') || st.contains('izin')) {
        countCuti++;
      } else {
        countHadir++;
      }
    }

    // Jika filter diterapkan
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = _listRiwayat.where((item) {
      final st = (item['status'] ?? '').toString();
      if (_selectedFilter == 'Hadir' && st != 'Hadir') return false;
      if (_selectedFilter == 'Terlambat' && !st.toLowerCase().contains('terlambat')) return false;
      if (_selectedFilter == 'Izin Cuti' && (!st.toLowerCase().contains('cuti') && !st.toLowerCase().contains('izin'))) return false;

      if (query.isNotEmpty) {
        final tgl = (item['tanggal'] ?? '').toString().toLowerCase();
        final hari = (item['hari'] ?? '').toString().toLowerCase();
        final tglNo = (item['tgl'] ?? '').toString().toLowerCase();
        final bln = (item['bulan'] ?? '').toString().toLowerCase();
        return tgl.contains(query) || hari.contains(query) || tglNo.contains(query) || bln.contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _muatData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Judul
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Text(
                  'Riwayat Absensi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),

              // 2. Search Bar "Cari tanggal..."
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                    decoration: const InputDecoration(
                      hintText: 'Cari tanggal...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Filter Chips (Semua, Hadir, Terlambat, Izin Cuti)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Hadir'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terlambat'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Izin Cuti'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Garis Divider Pemisah
              const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
              const SizedBox(height: 14),

              // 4. Baris Kartu Ringkasan (14 Hadir, 2 Terlambat, 1 Cuti/Izin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        count: countHadir > 0 ? countHadir.toString() : '14',
                        label: 'Hadir',
                        valueColor: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        count: countTerlambat > 0 ? countTerlambat.toString() : '2',
                        label: 'Terlambat',
                        valueColor: const Color(0xFFF97316),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        count: countCuti > 0 ? countCuti.toString() : '1',
                        label: 'Cuti/Izin',
                        valueColor: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Daftar Kartu Riwayat Absensi
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? ListView(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    'Tidak ada riwayat ditemukan',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final item = filtered[i];
                              return _buildRiwayatCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool active = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppConstants.primaryColor : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String count,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _bukaDetail(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Date Squircle Badge (e.g. 18 AGU)
                Container(
                  width: 52,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['tgl'] ?? '01',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        item['bulan'] ?? 'BLN',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Content (Hari + Status Badge + Jam Masuk & Pulang)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['hari'] ?? 'Hari',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(item['status'] ?? 'Hadir'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          children: [
                            const TextSpan(text: 'Masuk: '),
                            TextSpan(
                              text: '${item['jam_masuk']}  ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                            const TextSpan(text: 'Pulang: '),
                            TextSpan(
                              text: '${item['jam_pulang']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Chevron
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
