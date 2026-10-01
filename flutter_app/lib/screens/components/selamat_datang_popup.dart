import 'package:flutter/material.dart';

/// Modal Popup "Selamat Datang!"
/// Dibuat 100% persis sesuai desain Figma yang dikirimkan user:
/// - Judul: "Selamat Datang!"
/// - Ikon: Kotak hijau sage (#A3B995) dengan lingkaran hijau tua (#48742C) & centang putih
/// - Nama: "Super Admin" (Admin) / "Lilit Ransink" (Karyawan)
/// - Role: "Administrator" / "Teknisi Drone"
/// - Info: "Login berhasil. Menghubungkan ke dashboard..."
/// - Tombol: "Lanjutkan ke Dashboard" berwarna ungu navy (#4F5BA8)
class SelamatDatangPopup extends StatelessWidget {
  final String nama;
  final String roleTitle;
  final VoidCallback? onLanjutkan;

  const SelamatDatangPopup({
    super.key,
    required this.nama,
    required this.roleTitle,
    this.onLanjutkan,
  });

  /// Helper untuk menampilkan popup Selamat Datang untuk Admin
  static Future<void> showAdmin(
    BuildContext context, {
    String nama = 'Super Admin',
    String roleTitle = 'Administrator',
    VoidCallback? onLanjutkan,
  }) {
    return show(
      context,
      nama: nama,
      roleTitle: roleTitle,
      onLanjutkan: onLanjutkan,
    );
  }

  /// Helper untuk menampilkan popup Selamat Datang untuk Karyawan
  static Future<void> showKaryawan(
    BuildContext context, {
    String nama = 'Lilit Ransink',
    String roleTitle = 'Teknisi Drone',
    VoidCallback? onLanjutkan,
  }) {
    return show(
      context,
      nama: nama,
      roleTitle: roleTitle,
      onLanjutkan: onLanjutkan,
    );
  }

  /// Helper umum untuk menampilkan dialog Selamat Datang
  static Future<void> show(
    BuildContext context, {
    required String nama,
    required String roleTitle,
    VoidCallback? onLanjutkan,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: false, // Mengharuskan klik tombol atau pop manual
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
            child: SelamatDatangPopup(
              nama: nama,
              roleTitle: roleTitle,
              onLanjutkan: onLanjutkan ?? () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Judul Kiri Atas: "Selamat Datang!"
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Bagian Konten Tengah
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon Kotak Hijau Sage dengan Lingkaran Centang Putih
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA3B995),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA3B995).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF48742C),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Nama User
                Text(
                  nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),

                // Jabatan / Role
                Text(
                  roleTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // Subtitle Info
                const Text(
                  'Login berhasil. Menghubungkan ke dashboard...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Tombol "Lanjutkan ke Dashboard"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F5BA8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onLanjutkan ?? () => Navigator.of(context).pop(),
              child: const Text(
                'Lanjutkan ke Dashboard',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
