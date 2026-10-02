import 'package:flutter/material.dart';
import '../pengajuan_cuti_screen.dart';
import '../laporan_screen.dart';

/// Model notifikasi karyawan
class NotifikasiItem {
  final String id;
  final String tipe; // 'cuti' | 'laporan' | 'info'
  final String judul;
  final String pesan;
  final String waktu;
  final VoidCallback? onTap;

  const NotifikasiItem({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.onTap,
  });
}

/// Popup Notifikasi Karyawan
/// Dibuat persis 100% sesuai screenshot desain Figma:
/// - Judul "Notifikasi" dengan tombol silang (x) di kanan atas
/// - Kartu 1: Cuti Disetujui (Ikon centang putih di lingkaran hijau tua berlatar hijau muda pastel)
/// - Kartu 2: Jangan Lupa Laporan (Ikon tanda seru putih di lingkaran oranye tua berlatar peach pastel)
/// - Background kartu abu-abu muda (#ECECEC) dengan rounded corner halus
class NotifikasiKaryawanPopup extends StatelessWidget {
  final VoidCallback? onTapCuti;
  final VoidCallback? onTapLaporan;
  final List<NotifikasiItem>? items;

  const NotifikasiKaryawanPopup({
    super.key,
    this.onTapCuti,
    this.onTapLaporan,
    this.items,
  });

  /// Helper untuk menampilkan popup Notifikasi (Dialog Modal)
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onTapCuti,
    VoidCallback? onTapLaporan,
    List<NotifikasiItem>? items,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 0,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 390),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: NotifikasiKaryawanPopup(
              onTapCuti: onTapCuti,
              onTapLaporan: onTapLaporan,
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper alternatif untuk menampilkan sebagai Bottom Sheet jika dibutuhkan
  static Future<void> showBottomSheet(
    BuildContext context, {
    VoidCallback? onTapCuti,
    VoidCallback? onTapLaporan,
    List<NotifikasiItem>? items,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: NotifikasiKaryawanPopup(
            onTapCuti: onTapCuti,
            onTapLaporan: onTapLaporan,
            items: items,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: "Notifikasi" & Tombol 'X'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: Color(0xFFB3B3B3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. KARTU NOTIFIKASI
          if (items != null && items!.isNotEmpty)
            ...items!.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildItemCard(
                    context: context,
                    tipe: it.tipe,
                    judul: it.judul,
                    pesan: it.pesan,
                    waktu: it.waktu,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (it.onTap != null) {
                        it.onTap!();
                      } else if (it.tipe == 'cuti') {
                        _handleNavigasiCuti(context);
                      } else if (it.tipe == 'laporan') {
                        _handleNavigasiLaporan(context);
                      }
                    },
                  ),
                ))
          else ...[
            // Default Item 1: Cuti Disetujui
            _buildItemCard(
              context: context,
              tipe: 'cuti',
              judul: 'Cuti Disetujui',
              pesan: 'Pengajuan cuti 25 Agustus telah disetujui admin.',
              waktu: '2 jam lalu',
              onTap: () {
                Navigator.of(context).pop();
                if (onTapCuti != null) {
                  onTapCuti!();
                } else {
                  _handleNavigasiCuti(context);
                }
              },
            ),
            const SizedBox(height: 12),

            // Default Item 2: Jangan Lupa Laporan
            _buildItemCard(
              context: context,
              tipe: 'laporan',
              judul: 'Jangan Lupa Laporan',
              pesan: 'Laporan harian hari ini belum dikirim.',
              waktu: '4 jam lalu',
              onTap: () {
                Navigator.of(context).pop();
                if (onTapLaporan != null) {
                  onTapLaporan!();
                } else {
                  _handleNavigasiLaporan(context);
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  void _handleNavigasiCuti(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PengajuanCutiScreen(initialTabIndex: 1),
      ),
    );
  }

  void _handleNavigasiLaporan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LaporanScreen()),
    );
  }

  Widget _buildItemCard({
    required BuildContext context,
    required String tipe,
    required String judul,
    required String pesan,
    required String waktu,
    required VoidCallback onTap,
  }) {
    final bool isCuti = tipe == 'cuti';

    // Warna container luar & lingkaran dalam sesuai mockup Figma
    final Color outerBoxColor = isCuti ? const Color(0xFF9CE093) : const Color(0xFFF3C581);
    final Color innerCircleColor = isCuti ? const Color(0xFF4A7A30) : const Color(0xFFF2A84C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kotak Ikon Kiri (52 x 52)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: outerBoxColor,
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: innerCircleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCuti
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : const Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Teks Notifikasi (Judul, Pesan, Waktu)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pesan,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    waktu,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
