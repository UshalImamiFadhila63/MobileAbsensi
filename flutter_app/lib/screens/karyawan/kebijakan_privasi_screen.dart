import 'package:flutter/material.dart';

/// Halaman Kebijakan Privasi Karyawan
/// Dibuat 100% persis sesuai desain mockup Figma:
/// 1. Top bar: Warna biru indigo (#4F5BA8) dengan chevron kiri (<) & Judul "Kebijakan Privasi"
/// 2. Subjudul: "Terakhir diperbarui 1 Januari 2026"
/// 3. Kartu Putih Berisi 4 Bagian Kebijakan:
///    - Data yang kami kumpulkan
///    - Cara kami menggunakannya
///    - Keamanan data
///    - Hak kamu
class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F5BA8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subjudul Tanggal Pembaruan
              const Text(
                'Terakhir diperbarui 1 Januari 2026',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),

              // KARTU PUTIH ISI KEBIJAKAN PRIVASI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian 1
                    _SectionItem(
                      title: 'Data yang kami kumpulkan',
                      body:
                          'Kami menyimpan data profil, riwayat absensi, dan laporan yang kamu buat untuk keperluan operasional.',
                    ),
                    SizedBox(height: 18),

                    // Bagian 2
                    _SectionItem(
                      title: 'Cara kami menggunakannya',
                      body:
                          'Data dipakai untuk mencatat kehadiran, memantau misi drone, dan menyusun laporan kerja tim.',
                    ),
                    SizedBox(height: 18),

                    // Bagian 3
                    _SectionItem(
                      title: 'Keamanan data',
                      body:
                          'Data disimpan terenkripsi dan hanya bisa diakses oleh pihak yang berwenang.',
                    ),
                    SizedBox(height: 18),

                    // Bagian 4
                    _SectionItem(
                      title: 'Hak kamu',
                      body:
                          'Kamu bisa meminta perubahan atau penghapusan data lewat admin divisi.',
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
}

class _SectionItem extends StatelessWidget {
  final String title;
  final String body;

  const _SectionItem({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
