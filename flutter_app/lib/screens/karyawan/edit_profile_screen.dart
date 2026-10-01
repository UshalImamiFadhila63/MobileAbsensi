import 'package:flutter/material.dart';
import '../../core/api_service.dart';

/// Halaman Edit Profil Karyawan
/// Dibuat 100% persis sesuai desain mockup Figma:
/// 1. Top bar: Warna biru indigo (#4F5BA8) dengan chevron kiri (<) & Judul "Edit Profil"
/// 2. Avatar Profil:
///    - Kotak rounded lavender-indigo (#8E9DC8) dengan inisial "AF"
///    - Tombol lingkaran kamera (#4F5BA8 berbingkai putih) di sudut kanan bawah
/// 3. Kartu Formulir:
///    - Nama Lengkap (Editable)
///    - NIP (Read-only/Disabled abu-abu)
///    - Divisi (Read-only/Disabled abu-abu)
///    - Email (Editable)
///    - Nomor telepon (Editable)
/// 4. Tombol Bawah: "Simpan Perubahan" (#4F5BA8)
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _teleponCtrl;
  late final String _nip;
  late final String _divisi;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final nama = widget.user['nama'] ?? 'Ahmad Fauzi';
    final email = widget.user['email'] ?? 'ahmad.f@drone.id';
    final hp = widget.user['no_hp'] ?? '0812 3456 7890';
    _nip = widget.user['nip'] ?? 'DA-2024-0012';
    _divisi = widget.user['divisi'] ?? 'Drone Agriculture';

    _namaCtrl = TextEditingController(text: nama);
    _emailCtrl = TextEditingController(text: email);
    _teleponCtrl = TextEditingController(text: hp);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'AF';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _simpanPerubahan() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateProfileTextOnly(
        nama: _namaCtrl.text.trim(),
        noHp: _teleponCtrl.text.trim(),
        jabatan: widget.user['jabatan'] ?? 'Teknisi Drone Senior',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4F5BA8),
          content: Text('Profil berhasil diperbarui!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(_namaCtrl.text);

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
          'Edit Profil',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  children: [
                    // 1. AVATAR PROFIL KARYAWAN
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E9DC8), // Lavender-indigo pastel persis Figma
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          // Ikon Kamera Kecil di Sudut Kanan Bawah
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F5BA8),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. KARTU DETAIL FORMULIR
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Field 1: Nama Lengkap (Editable)
                          _buildEditableField('Nama Lengkap', _namaCtrl),
                          const SizedBox(height: 16),

                          // Field 2: NIP (Disabled/Read-only)
                          _buildDisabledField('NIP', _nip),
                          const SizedBox(height: 16),

                          // Field 3: Divisi (Disabled/Read-only)
                          _buildDisabledField('Divisi', _divisi),
                          const SizedBox(height: 16),

                          // Field 4: Email (Editable)
                          _buildEditableField('Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),

                          // Field 5: Nomor telepon (Editable)
                          _buildEditableField('Nomor telepon', _teleponCtrl, keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. TOMBOL BAWAH: "Simpan Perubahan"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F5BA8), // Warna biru-keunguan utama
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saving ? null : _simpanPerubahan,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB), // Abu-abu disabled persis mockup
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
