import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_service.dart';
import '../components/konfirmasi_pengajuan_popup.dart';

/// Halaman Pengajuan Cuti Karyawan
/// Dibuat persis 100% sesuai screenshot desain Figma yang dikirimkan user:
/// 1. Top bar: Tombol back panah hitam + Judul "Pengajuan Cuti" + Divider halus
/// 2. Tab Bar 3 Segmen:
///    - "Ajukan Cuti" (Tab 0)
///    - "Status & Riwayat" (Tab 1)
///    - "Info Cuti" (Tab 2)
/// 3. Tab 0 - Form Ajukan Cuti:
///    - JENIS CUTI (Dropdown)
///    - TANGGAL MULAI & TANGGAL SELESAI (Date pickers)
///    - ALASAN CUTI (Textarea)
///    - Lampiran (Opsional) (Dashed box)
///    - Tombol "Ajukan Cuti" dengan ikon pesawat kertas
/// 4. Tab 1 - Status & Riwayat:
///    - Kartu Cuti Tahunan (Disetujui)
///    - Kartu Cuti Sakit (Disetujui)
///    - Kartu Cuti Tahunan (Ditolak) dengan kotak alasan penolakan warna merah muda
/// 5. Tab 2 - Info Cuti:
///    - Kartu Cuti Tahunan (12 hari/tahun, 3 hari, 9 hari) berlatar ungu pastel (#DFE1F4)
///    - Kartu Cuti Sakit (Tidak terbatas, 1 hari, —) berlatar hijau pastel (#CEF4C9)
///    - Kartu Cuti Darurat (3 hari/tahun, 0 hari, 3 hari) berlatar oranye pastel (#FBDCB2)
class PengajuanCutiScreen extends StatefulWidget {
  final int initialTabIndex;

  const PengajuanCutiScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<PengajuanCutiScreen> createState() => _PengajuanCutiScreenState();
}

class _PengajuanCutiScreenState extends State<PengajuanCutiScreen> {
  late int _selectedTab;
  int _riwayatRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR: Back Arrow + Title
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF111827),
                      size: 22,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Pengajuan Cuti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 2. TAB HEADER 3 SEGMEN
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _buildTabItem(0, 'Ajukan\nCuti'),
                  _buildTabItem(1, 'Status &\nRiwayat'),
                  _buildTabItem(2, 'Info\nCuti'),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

            // 3. TAB CONTENT
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _TabAjukanCuti(
                    onSuccess: () => setState(() {
                      _selectedTab = 1;
                      _riwayatRefreshKey++;
                    }),
                  ),
                  _TabStatusRiwayat(key: ValueKey(_riwayatRefreshKey)),
                  const _TabInfoCuti(),
                ],
              ),
            ),
          ],
        ),
      ),

      // 4. BOTTOM NAVIGATION BAR (Sesuai Mockup)
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, Icons.home_rounded, 'Home'),
                _buildBottomNavItem(1, Icons.calendar_month_rounded, 'Absensi'),
                _buildBottomNavItem(2, Icons.access_time_rounded, 'Riwayat'),
                _buildBottomNavItem(3, Icons.description_rounded, 'Laporan'),
                _buildBottomNavItem(4, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedTab = index;
          if (index == 1) {
            _riwayatRefreshKey++;
          }
        }),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? const Color(0xFF4F5BA8) : const Color(0xFF6B7280),
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isHome = index == 0;
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isHome ? const Color(0xFF4F5BA8) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHome ? FontWeight.bold : FontWeight.normal,
              color: isHome ? const Color(0xFF4F5BA8) : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 0: FORM AJUKAN CUTI
// ==========================================
class _TabAjukanCuti extends StatefulWidget {
  final VoidCallback onSuccess;

  const _TabAjukanCuti({required this.onSuccess});

  @override
  State<_TabAjukanCuti> createState() => _TabAjukanCutiState();
}

class _TabAjukanCutiState extends State<_TabAjukanCuti> {
  final _formKey = GlobalKey<FormState>();
  final _alasanCtrl = TextEditingController();
  String? _jenisCuti;
  DateTime? _mulai;
  DateTime? _selesai;
  File? _lampiranFile;
  bool _submitting = false;

  final List<String> _jenisCutiOptions = [
    'Cuti Tahunan',
    'Cuti Sakit',
    'Cuti Darurat',
    'Izin',
    'Lainnya',
  ];

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(bool isMulai) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isMulai ? (_mulai ?? DateTime.now()) : (_selesai ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _mulai = picked;
          if (_selesai != null && _selesai!.isBefore(_mulai!)) {
            _selesai = _mulai;
          }
        } else {
          _selesai = picked;
        }
      });
    }
  }

  Future<void> _pilihLampiran() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        setState(() => _lampiranFile = File(picked.path));
      }
    } catch (_) {}
  }

  Future<void> _kirimPengajuan() async {
    if (_jenisCuti == null || _jenisCuti!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih Jenis Cuti')),
      );
      return;
    }
    if (_mulai == null || _selesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih Tanggal Mulai dan Selesai')),
      );
      return;
    }
    if (_alasanCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan jelaskan alasan cuti Anda')),
      );
      return;
    }

    final konfirmasi = await KonfirmasiPengajuanDialog.show(context);
    if (konfirmasi != true) return;

    setState(() => _submitting = true);
    final fmt = DateFormat('yyyy-MM-dd');

    try {
      final res = await ApiService.ajukanCuti(
        jenisCuti: _jenisCuti!,
        tanggalMulai: fmt.format(_mulai!),
        tanggalSelesai: fmt.format(_selesai!),
        alasan: _alasanCtrl.text.trim(),
        lampiran: _lampiranFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2E7D32),
          content: Text(res['message'] ?? 'Pengajuan cuti berhasil dikirim!'),
        ),
      );

      _alasanCtrl.clear();
      setState(() {
        _jenisCuti = null;
        _mulai = null;
        _selesai = null;
        _lampiranFile = null;
      });

      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MM/dd/yyyy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // KARTU PUTIH FORM
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. JENIS CUTI
                const Text(
                  'JENIS CUTI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(_jenisCuti),
                  initialValue: _jenisCuti,
                  hint: const Text(
                    'Pilih Jenis Cuti',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F5BA8), width: 1.5),
                    ),
                  ),
                  items: _jenisCutiOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt, style: const TextStyle(fontSize: 14, color: Color(0xFF111827))),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _jenisCuti = val),
                ),
                const SizedBox(height: 16),

                // 2. TANGGAL MULAI & TANGGAL SELESAI
                Row(
                  children: [
                    // Tanggal Mulai
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TANGGAL MULAI',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pilihTanggal(true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _mulai != null ? dateFmt.format(_mulai!) : 'mm/dd/yyyy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _mulai != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tanggal Selesai
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TANGGAL SELESAI',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pilihTanggal(false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _selesai != null ? dateFmt.format(_selesai!) : 'mm/dd/yyyy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selesai != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. ALASAN CUTI
                const Text(
                  'ALASAN CUTI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _alasanCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan Alasan Cuti Anda...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF4F5BA8), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Lampiran (Opsional) Kotak Bergaris Putus-putus
                InkWell(
                  onTap: _pilihLampiran,
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(
                    painter: const _DashedRectPainter(
                      color: Color(0xFFB0B7C3),
                      radius: 14,
                      dashWidth: 6,
                      dashSpace: 4,
                      strokeWidth: 1.2,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                      children: [
                        Transform.rotate(
                          angle: 0.7,
                          child: const Icon(
                            Icons.attach_file_rounded,
                            color: Color(0xFF4B5563),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _lampiranFile != null
                                    ? _lampiranFile!.path.split(Platform.pathSeparator).last
                                    : 'Lampiran (Opsional)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _lampiranFile != null ? 'Ketuk untuk mengganti file' : 'Surat Dokter, dll',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // TOMBOL "Ajukan Cuti"
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F5BA8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _submitting ? null : _kirimPengajuan,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.2,
                        child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Ajukan Cuti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TAB 1: STATUS & RIWAYAT
// ==========================================
class _TabStatusRiwayat extends StatefulWidget {
  const _TabStatusRiwayat({super.key});

  @override
  State<_TabStatusRiwayat> createState() => _TabStatusRiwayatState();
}

class _TabStatusRiwayatState extends State<_TabStatusRiwayat> {
  late Future<List<dynamic>> _future;

  // Data default persis 100% sesuai screenshot Figma Gambar 3
  final List<Map<String, dynamic>> _mockList = [
    {
      'id': 1,
      'jenis_cuti': 'Cuti Tahunan',
      'periode': '15 – 16 Agt 2026',
      'durasi': '2 hari',
      'status': 'Disetujui',
    },
    {
      'id': 2,
      'jenis_cuti': 'Cuti Sakit',
      'periode': '3 Jul 2026',
      'durasi': '1 hari',
      'status': 'Disetujui',
    },
    {
      'id': 3,
      'jenis_cuti': 'Cuti Tahunan',
      'periode': '20 – 22 Jun 2026',
      'durasi': '3 hari',
      'status': 'Ditolak',
      'alasan_tolak': 'Alasan penolakan: Staf lapangan terlalu sedikit saat itu.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _future = ApiService.informasiCutiSaya();
  }

  void _muatUlang() {
    setState(() {
      _future = ApiService.informasiCutiSaya();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _muatUlang(),
      child: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snap) {
          List<Map<String, dynamic>> listToDisplay = _mockList;

          if (snap.hasData && snap.data!.isNotEmpty) {
            final parsed = <Map<String, dynamic>>[];
            for (final it in snap.data!) {
              final statusRaw = (it['status'] ?? 'menunggu').toString().toLowerCase();
              String statusDisplay = 'Menunggu';
              if (statusRaw == 'disetujui' || statusRaw == 'diterima') {
                statusDisplay = 'Disetujui';
              } else if (statusRaw == 'ditolak') {
                statusDisplay = 'Ditolak';
              }

              parsed.add({
                'id': it['id'],
                'jenis_cuti': it['jenis_cuti'] ?? 'Cuti Tahunan',
                'periode': '${it['tanggal_mulai']} – ${it['tanggal_selesai']}',
                'durasi': '${it['durasi'] ?? 1} hari',
                'status': statusDisplay,
                'alasan_tolak': it['catatan_admin'] != null && it['catatan_admin'].toString().isNotEmpty
                    ? 'Alasan penolakan: ${it['catatan_admin']}'
                    : null,
              });
            }
            if (parsed.isNotEmpty) listToDisplay = parsed;
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: listToDisplay.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = listToDisplay[index];
              return _buildRiwayatCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'Disetujui').toString();
    final bool isDisetujui = status.toLowerCase() == 'disetujui';
    final bool isDitolak = status.toLowerCase() == 'ditolak';

    // Warna badge sesuai screenshot Figma
    final Color badgeBg = isDisetujui
        ? const Color(0xFFCFF3CA)
        : (isDitolak ? const Color(0xFFF9C2BD) : const Color(0xFFFEF3C7));

    final Color badgeTextColor = isDisetujui
        ? const Color(0xFF2E6930)
        : (isDitolak ? const Color(0xFFC53030) : const Color(0xFFD97706));

    final String? alasanTolak = item['alasan_tolak'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Judul Cuti & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['jenis_cuti'] ?? 'Cuti Tahunan',
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['periode']} • ${item['durasi']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),

          // Kotak Alasan Penolakan Jika Ditolak
          if (isDitolak && alasanTolak != null && alasanTolak.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDC6C2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alasanTolak,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFFC53030),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================
// TAB 2: INFO CUTI
// ==========================================
class _TabInfoCuti extends StatelessWidget {
  const _TabInfoCuti();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // KARTU 1: CUTI TAHUNAN (Ungu Pastel #DFE1F4)
        _buildInfoCard(
          icon: Icons.confirmation_number_outlined,
          iconColor: const Color(0xFF4F5BA8),
          iconBg: const Color(0xFFDFE1F4),
          title: 'Cuti Tahunan',
          statBg: const Color(0xFFDFE1F4),
          statColor: const Color(0xFF4F5BA8),
          k1Value: '12 hari/\ntahun',
          k1Label: 'Kuota',
          k2Value: '3 hari',
          k2Label: 'Terpakai',
          k3Value: '9 hari',
          k3Label: 'Sisa',
        ),
        const SizedBox(height: 14),

        // KARTU 2: CUTI SAKIT (Hijau Pastel #CEF4C9)
        _buildInfoCard(
          icon: Icons.confirmation_number_outlined,
          iconColor: const Color(0xFF2E6930),
          iconBg: const Color(0xFFCEF4C9),
          title: 'Cuti Sakit',
          statBg: const Color(0xFFCEF4C9),
          statColor: const Color(0xFF2E6930),
          k1Value: 'Tidak\nterbatas',
          k1Label: 'Kuota',
          k2Value: '1 hari',
          k2Label: 'Terpakai',
          k3Value: '—',
          k3Label: 'Sisa',
        ),
        const SizedBox(height: 14),

        // KARTU 3: CUTI DARURAT (Oranye Pastel #FBDCB2)
        _buildInfoCard(
          icon: Icons.confirmation_number_outlined,
          iconColor: const Color(0xFFE06A1B),
          iconBg: const Color(0xFFFBDCB2),
          title: 'Cuti Darurat',
          statBg: const Color(0xFFFBDCB2),
          statColor: const Color(0xFFE06A1B),
          k1Value: '3 hari/\ntahun',
          k1Label: 'Kuota',
          k2Value: '0 hari',
          k2Label: 'Terpakai',
          k3Value: '3 hari',
          k3Label: 'Sisa',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Color statBg,
    required Color statColor,
    required String k1Value,
    required String k1Label,
    required String k2Value,
    required String k2Label,
    required String k3Value,
    required String k3Label,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul & Ikon Tiket/Cuti
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Kotak Statistik (Kuota, Terpakai, Sisa)
          Row(
            children: [
              Expanded(
                child: _buildStatBox(statBg, statColor, k1Value, k1Label),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(statBg, statColor, k2Value, k2Label),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(statBg, statColor, k3Value, k3Label),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(Color bg, Color textColor, String value, String label) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk menggambar border putus-putus (dashed border)
/// sesuai desain Figma pada kotak Lampiran
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.radius = 14.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}

