import 'package:flutter/material.dart';

/// Modal / BottomSheet Notifikasi Admin
/// Dibuat persis sesuai desain mockup Notifikasi
class NotifikasiSheet extends StatelessWidget {
  final int jumlahCutiMenunggu;
  final int jumlahBelumAbsen;
  final int jumlahTerlambat;
  final VoidCallback? onTapCuti;
  final VoidCallback? onTapBelumAbsen;
  final VoidCallback? onTapTerlambat;

  const NotifikasiSheet({
    super.key,
    this.jumlahCutiMenunggu = 3,
    this.jumlahBelumAbsen = 5,
    this.jumlahTerlambat = 2,
    this.onTapCuti,
    this.onTapBelumAbsen,
    this.onTapTerlambat,
  });

  /// Helper untuk menampilkan modal Notifikasi
  static Future<void> show(
    BuildContext context, {
    int jumlahCutiMenunggu = 3,
    int jumlahBelumAbsen = 5,
    int jumlahTerlambat = 2,
    VoidCallback? onTapCuti,
    VoidCallback? onTapBelumAbsen,
    VoidCallback? onTapTerlambat,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotifikasiSheet(
        jumlahCutiMenunggu: jumlahCutiMenunggu,
        jumlahBelumAbsen: jumlahBelumAbsen,
        jumlahTerlambat: jumlahTerlambat,
        onTapCuti: onTapCuti,
        onTapBelumAbsen: onTapBelumAbsen,
        onTapTerlambat: onTapTerlambat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Notifikasi" dan Icon 'X'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),

          // Item 1: Pengajuan Cuti (Icon Kalkulator/Kalender di lingkaran ungu muda)
          _buildNotifItem(
            context: context,
            icon: Icons.calculate,
            iconColor: const Color(0xFF4F5BA8), // Ungu / Navy brand
            circleColor: const Color(0xFFD8DDF8), // Soft lavender
            title: '$jumlahCutiMenunggu Pengajuan Cuti',
            subtitle: 'menunggu persetujuan',
            onTap: () {
              Navigator.of(context).pop();
              onTapCuti?.call();
            },
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),

          // Item 2: Karyawan belum absen (Icon Orang di lingkaran oranye muda)
          _buildNotifItem(
            context: context,
            icon: Icons.person_rounded,
            iconColor: const Color(0xFFEA8C28), // Orange
            circleColor: const Color(0xFFFDE8D4), // Soft peach
            title: '$jumlahBelumAbsen Karyawan belum absen',
            subtitle: 'masuk hari ini',
            onTap: () {
              Navigator.of(context).pop();
              onTapBelumAbsen?.call();
            },
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),

          // Item 3: Karyawan terlambat (Icon Jam di lingkaran pink/merah muda)
          _buildNotifItem(
            context: context,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFE03D55), // Red / Pink
            circleColor: const Color(0xFFFCD5DC), // Soft pink
            title: '$jumlahTerlambat Karyawan terlambat',
            subtitle: 'masuk ini',
            onTap: () {
              Navigator.of(context).pop();
              onTapTerlambat?.call();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotifItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color circleColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Lingkaran Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 14),

            // Judul & Keterangan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Trailing: "Hari ini >"
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hari ini',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
