import 'package:flutter/material.dart';

class KonfirmasiPengajuanDialog extends StatelessWidget {
  const KonfirmasiPengajuanDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => const KonfirmasiPengajuanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Judul + Tombol X)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konfirmasi Pengajuan',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider tipis persis screenshot
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

          // 2. Isi Pesan & Tombol Aksi
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apakah Anda yakin ingin mengajukan cuti ini?\nPengajuan akan diteruskan ke admin untuk\ndisetujui.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol "Ya, Ajukan" (Ungu/Indigo Theme)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F5BA8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ya, Ajukan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol "Batal" (Abu-abu Muda)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
