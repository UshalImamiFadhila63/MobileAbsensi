import 'package:flutter/material.dart';

/// Halaman Detail Absensi Karyawan
/// Dibuat persis 100% sesuai screenshot desain Figma yang dikirimkan user:
/// 1. Top bar: Tombol back lingkaran ungu navy (#4F5BA8) + Judul "Detail Absensi" + Divider halus
/// 2. Ikon Sukses: Kotak hijau pastel (#C5F2BF) dengan lingkaran hijau tua (#48742C) & centang putih
/// 3. Kartu 1: INFORMASI ABSENSI dengan border radius 20, divider antar baris
///    - Status Kehadiran dengan warna akurat:
///      * Terlambat -> Oranye (#FF8D28)
///      * Hadir — Tepat Waktu -> Hijau (#48742C)
///      * Izin Cuti -> Biru Navy (#4F5BA8)
///      * Tidak Hadir -> Merah (#DC2626)
/// 4. Kartu 2: LOKASI GPS dengan map preview (#C9EFC4), ikon pin biru, dan koordinat
class DetailAbsensiScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onBack;

  const DetailAbsensiScreen({
    super.key,
    required this.item,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Parsing Status Kehadiran & Warna
    final rawStatus = (item['status'] ?? 'Hadir').toString();
    final bool isCuti = rawStatus.toLowerCase().contains('cuti') ||
        rawStatus.toLowerCase().contains('izin');
    final bool isTerlambat = rawStatus.toLowerCase().contains('terlambat');
    final bool isAlpha = rawStatus.toLowerCase().contains('alpha') ||
        rawStatus.toLowerCase().contains('tidak');

    String statusDisplay;
    Color statusColor;

    if (isTerlambat) {
      statusDisplay = 'Terlambat';
      statusColor = const Color(0xFFFF8D28); // Oranye akurat sesuai mockup
    } else if (isCuti) {
      statusDisplay = 'Izin Cuti';
      statusColor = const Color(0xFF4F5BA8); // Biru/Ungu brand akurat
    } else if (isAlpha) {
      statusDisplay = 'Tidak Hadir';
      statusColor = const Color(0xFFDC2626); // Merah
    } else {
      statusDisplay = 'Hadir — Tepat Waktu';
      statusColor = const Color(0xFF48742C); // Hijau zaitun akurat
    }

    // 2. Parsing Tanggal
    final tanggalLengkap = _formatTanggal(item);

    // 3. Parsing Jam & Durasi Kerja
    final jamMasukRaw = (item['jam_masuk'] ?? '—').toString();
    final jamPulangRaw = (item['jam_pulang'] ?? '—').toString();

    final String jamMasuk = isCuti || jamMasukRaw == '—' || jamMasukRaw.isEmpty
        ? '—'
        : (jamMasukRaw.contains('WIB') ? jamMasukRaw : '$jamMasukRaw WIB');

    final String jamPulang = isCuti || jamPulangRaw == '—' || jamPulangRaw.isEmpty
        ? '—'
        : (jamPulangRaw.contains('WIB') ? jamPulangRaw : '$jamPulangRaw WIB');

    final String totalJamKerja = isCuti
        ? '—'
        : (item['total_jam']?.toString() ??
            _hitungTotalJamKerja(jamMasukRaw, jamPulangRaw));

    // 4. Parsing Lokasi & Metode
    final String lokasiMasuk = isCuti ? '—' : 'Kantor Pusat, Jl. Sudirman';
    final String metodeVerifikasi =
        item['metode_verifikasi']?.toString() ?? 'Face Recognition + GPS';

    final String koordinat =
        item['koordinat']?.toString() ?? '-6.2088° S, 106.8456° E • Akurasi ±5m';

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && onBack != null) {
          onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP BAR: Back Button + Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    // Lingkaran Tombol Back Biru-Ungu
                    InkWell(
                      onTap: () {
                        if (onBack != null) {
                          onBack!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F5BA8),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Teks Judul
                    const Text(
                      'Detail Absensi',
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

              // Divider Halus Membentang Penuh
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFE5E7EB),
              ),

              // 2. KONTEN DETAIL ABSENSI
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    const SizedBox(height: 20),

                    // IKON SQUIRCLE SUKSES HIJAU
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5F2BF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFF48742C),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // KARTU 1: INFORMASI ABSENSI
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: INFORMASI ABSENSI
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                            child: Text(
                              'INFORMASI ABSENSI',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 1. Tanggal
                          _buildTableRow('Tanggal', tanggalLengkap),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 2. Jam Masuk
                          _buildTableRow('Jam Masuk', jamMasuk),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 3. Jam Pulang
                          _buildTableRow('Jam Pulang', jamPulang),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 4. Total Jam Kerja
                          _buildTableRow('Total Jam Kerja', totalJamKerja),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 5. Status Kehadiran (Warna Kustom)
                          _buildTableRow(
                            'Status Kehadiran',
                            statusDisplay,
                            valueColor: statusColor,
                          ),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 6. Lokasi Masuk
                          _buildTableRow('Lokasi Masuk', lokasiMasuk),
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                          // 7. Metode Verifikasi
                          _buildTableRow('Metode Verifikasi', metodeVerifikasi),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KARTU 2: LOKASI GPS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD1D5DB),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOKASI GPS',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Map Box Preview Berlatar Hijau Lembut (#C9EFC4)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9EFC4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Lingkaran dasar / bayangan pin
                                Positioned(
                                  bottom: 35,
                                  child: Container(
                                    width: 34,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF23538F),
                                        width: 2.2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                // Ikon Pin Lokasi Biru (#23538F)
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF23538F),
                                  size: 38,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Teks Koordinat & Akurasi
                          Center(
                            child: Text(
                              koordinat,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTanggal(Map<String, dynamic> item) {
    if (item['tanggal_lengkap'] != null &&
        item['tanggal_lengkap'].toString().isNotEmpty) {
      return item['tanggal_lengkap'].toString();
    }

    final hari = item['hari']?.toString() ?? 'Senin';
    final tgl = item['tgl']?.toString() ?? '14';
    final blnRaw = item['bulan']?.toString() ?? 'AGU';
    final bln = _namaBulanLengkap(blnRaw);
    return '$hari, $tgl $bln 2026';
  }

  static String _namaBulanLengkap(String blnRaw) {
    final b = blnRaw.toUpperCase();
    if (b.contains('JAN')) return 'Januari';
    if (b.contains('FEB')) return 'Februari';
    if (b.contains('MAR')) return 'Maret';
    if (b.contains('APR')) return 'April';
    if (b.contains('MEI')) return 'Mei';
    if (b.contains('JUN')) return 'Juni';
    if (b.contains('JUL')) return 'Juli';
    if (b.contains('AGU')) return 'Agustus';
    if (b.contains('SEP')) return 'September';
    if (b.contains('OKT')) return 'Oktober';
    if (b.contains('NOV')) return 'November';
    if (b.contains('DES')) return 'Desember';
    return 'Agustus';
  }

  static String _hitungTotalJamKerja(String masuk, String pulang) {
    if (masuk == '—' || pulang == '—' || masuk.isEmpty || pulang.isEmpty) {
      return '—';
    }

    try {
      final cleanMasuk = masuk.replaceAll(' WIB', '').trim();
      final cleanPulang = pulang.replaceAll(' WIB', '').trim();

      final pMasuk = cleanMasuk.split(':');
      final pPulang = cleanPulang.split(':');

      if (pMasuk.length >= 2 && pPulang.length >= 2) {
        final mH = int.parse(pMasuk[0]);
        final mM = int.parse(pMasuk[1]);
        final pH = int.parse(pPulang[0]);
        final pM = int.parse(pPulang[1]);

        int totalMenitMasuk = mH * 60 + mM;
        int totalMenitPulang = pH * 60 + pM;

        if (totalMenitPulang >= totalMenitMasuk) {
          int selisih = totalMenitPulang - totalMenitMasuk;
          int jam = selisih ~/ 60;
          int menit = selisih % 60;

          if (menit == 0) {
            return '$jam jam';
          }
          return '$jam jam $menit menit';
        }
      }
    } catch (_) {}

    return '8 jam';
  }
}
