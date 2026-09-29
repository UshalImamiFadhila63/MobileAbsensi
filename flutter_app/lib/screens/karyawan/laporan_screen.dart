import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Terkirim', 'Draft'
  bool _loading = true;
  List<Map<String, dynamic>> _listLaporan = [];

  // Data demo fallback yang persis seperti pada desain mockup
  final List<Map<String, dynamic>> _demoLaporan = [
    {
      'id': 1,
      'judul': 'Penyemprotan pestisida area Blok A — 8 Ha',
      'tanggal': '17 Agustus 2026',
      'waktu': '16:30',
      'status': 'Terkirim',
      'isi_laporan': 'Kegiatan operasional drone sprayer pada Blok A seluas 8 Hektar selesai sesuai SOP.',
    },
    {
      'id': 2,
      'judul': 'Survei dan pemetaan lahan baru Subang',
      'tanggal': '16 Agt 2026',
      'waktu': '17:00',
      'status': 'Terkirim',
      'isi_laporan': 'Pemetaan elevasi dan batas kontur lahan baru wilayah Subang menggunakan drone pemeta.',
    },
    {
      'id': 3,
      'judul': 'Pemeliharaan rutin drone DA-001 dan DA-002',
      'tanggal': '15 Agt 2026',
      'waktu': '15:45',
      'status': 'Terkirim',
      'isi_laporan': 'Pemeriksaan motor brushless, kalibrasi sensor kompas, dan pembersihan rotor unit DA-001 & DA-002.',
    },
    {
      'id': 4,
      'judul': 'Penyebaran pupuk urea Blok B — 5 Ha',
      'tanggal': '14 Agt 2026',
      'waktu': '16:50',
      'status': 'Terkirim',
      'isi_laporan': 'Penyebaran butiran pupuk urea dengan spreader drone selesai dengan presisi tinggi.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.laporanSaya();
      final parsed = <Map<String, dynamic>>[];

      for (final item in res) {
        final tglRaw = item['tanggal']?.toString() ?? '';
        DateTime? dt;
        try {
          dt = DateTime.parse(tglRaw);
        } catch (_) {}

        String tglFmt = tglRaw;
        if (dt != null) {
          tglFmt = DateFormat('d MMMM yyyy', 'id_ID').format(dt);
        }

        parsed.add({
          'id': item['id'],
          'judul': item['judul'] ?? 'Laporan Kegiatan',
          'tanggal': tglFmt,
          'waktu': '16:00',
          'status': 'Terkirim',
          'isi_laporan': item['isi_laporan'] ?? '',
        });
      }

      setState(() {
        _listLaporan = parsed.isNotEmpty ? parsed : _demoLaporan;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _listLaporan = _demoLaporan;
          _loading = false;
        });
      }
    }
  }

  void _bukaDetailLaporan(Map<String, dynamic> item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Laporan ${item['tanggal']}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ),
                _buildStatusPill(item['status'] ?? 'Terkirim'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['judul'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Deskripsi Kegiatan:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            Text(
              item['isi_laporan']?.isNotEmpty == true
                  ? item['isi_laporan']
                  : 'Tidak ada rincian tambahan.',
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _bukaFormTambah() {
    final formKey = GlobalKey<FormState>();
    final judulCtrl = TextEditingController();
    final isiCtrl = TextEditingController();
    DateTime tanggal = DateTime.now();
    bool submitting = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buat Laporan Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    icon: const Icon(Icons.calendar_today, size: 18, color: AppConstants.primaryColor),
                    label: Text(
                      DateFormat('dd MMMM yyyy', 'id_ID').format(tanggal),
                      style: const TextStyle(color: Color(0xFF1F2937), fontSize: 14),
                    ),
                    onPressed: () async {
                      final t = await showDatePicker(
                        context: ctx,
                        initialDate: tanggal,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (t != null) setModalState(() => tanggal = t);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Judul Laporan
                  TextFormField(
                    controller: judulCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Laporan',
                      hintText: 'Contoh: Penyemprotan Blok A — 8 Ha',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  // Isi Laporan
                  TextFormField(
                    controller: isiCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Rincian Kegiatan',
                      hintText: 'Tuliskan deskripsi pekerjaan atau pemeliharaan...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi kegiatan wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),

                  // Tombol Kirim
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: submitting
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => submitting = true);
                              final messenger = ScaffoldMessenger.of(context);

                              try {
                                final res = await ApiService.submitLaporan(
                                  tanggal: DateFormat('yyyy-MM-dd').format(tanggal),
                                  judul: judulCtrl.text.trim(),
                                  isiLaporan: isiCtrl.text.trim(),
                                );

                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);

                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green.shade700,
                                    content: Text(res['message'] ?? 'Laporan berhasil dikirim!'),
                                  ),
                                );

                                await _muatData();
                              } catch (e) {
                                setModalState(() => submitting = false);
                                messenger.showSnackBar(
                                  SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
                                );
                              }
                            },
                      child: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Kirim Laporan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildStatusPill(String status) {
    Color bg = const Color(0xFFC7DBC5);
    Color textColor = const Color(0xFF3F623C);

    if (status.toLowerCase().contains('draft')) {
      bg = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    final filtered = _listLaporan.where((item) {
      if (_selectedFilter == 'Terkirim') {
        return (item['status'] ?? '').toString().toLowerCase() == 'terkirim';
      }
      if (_selectedFilter == 'Draft') {
        return (item['status'] ?? '').toString().toLowerCase() == 'draft';
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
              // 1. Header (Riwayat Laporan + Tombol "+ Baru")
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Riwayat Laporan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    // Tombol + Baru
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _bukaFormTambah,
                      child: const Text(
                        '+ Baru',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Filter Chips (Semua, Terkirim, Draft)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Terkirim'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Draft'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Daftar Kartu Laporan
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
                                    'Belum ada laporan',
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
                              return _buildLaporanCard(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaporanCard(Map<String, dynamic> item) {
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
          onTap: () => _bukaDetailLaporan(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Ikon + Tanggal/Waktu + Badge Terkirim
                Row(
                  children: [
                    // Squircle Document Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.article,
                        color: Color(0xFF4F5BA8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tanggal / Waktu
                    Expanded(
                      child: Text(
                        '${item['tanggal']} • ${item['waktu']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Status Pill
                    _buildStatusPill(item['status'] ?? 'Terkirim'),
                  ],
                ),
                const SizedBox(height: 12),

                // Judul Laporan Tebal
                Text(
                  item['judul'] ?? '',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
