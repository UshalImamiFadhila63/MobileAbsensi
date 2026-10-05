import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../../core/session.dart';
import '../../core/app_events.dart';

/// Halaman Edit Profil Karyawan
/// Dibuat 100% persis sesuai desain mockup Figma:
/// 1. Top bar: Warna biru indigo (#4F5BA8) dengan chevron kiri (<) & Judul "Edit Profil"
/// 2. Avatar Profil:
///    - Kotak rounded lavender-indigo (#8E9DC8) dengan foto profil / inisial nama
///    - Tombol lingkaran kamera (#4F5BA8 berbingkai putih) di sudut kanan bawah
///    - Mendukung upload / ganti foto profil dari Kamera atau Galeri
/// 3. Kartu Formulir:
///    - Nama Lengkap (Editable)
///    - NIP (Read-only/Disabled abu-abu)
///    - Divisi (Read-only/Disabled abu-abu)
///    - Email (Editable)
///    - Nomor telepon (Editable)
/// 4. Tombol Bawah: "Simpan Perubahan" (#4F5BA8) yang tersambung ke backend API
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

  File? _fotoBaru;
  String? _fotoUrlAwal;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final nama = widget.user['nama'] ?? 'Ahmad Fauzi';
    final email = widget.user['email'] ?? 'ahmad.f@drone.id';
    final hp = widget.user['no_hp'] ?? '0812 3456 7890';
    _nip = widget.user['nip'] ?? 'DA-2024-0012';
    _divisi = widget.user['divisi'] ?? 'Drone Agriculture';
    _fotoUrlAwal = AppConstants.getImageUrl(widget.user['foto_profil']);

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
    if (name.trim().isEmpty) return 'AF';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _pilihSumberFoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Foto Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF4F5BA8)),
                ),
                title: const Text('Ambil Foto (Kamera)', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Gunakan kamera ponsel untuk mengambil foto baru'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _ambilGambar(ImageSource.camera);
                },
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFF16A34A)),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih foto dari penyimpanan galeri perangkat'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _ambilGambar(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ambilGambar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _fotoBaru = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _simpanPerubahan() async {
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.orange, content: Text('Nama lengkap tidak boleh kosong')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.updateProfile(
        nama: nama,
        email: _emailCtrl.text.trim(),
        noHp: _teleponCtrl.text.trim(),
        jabatan: widget.user['jabatan'] ?? 'Teknisi Drone Senior',
        foto: _fotoBaru,
      );

      // Perbarui Session nama lokal & broadcast event ke Home & Profile
      await Session.setNama(nama);
      AppEvents.notifyProfileUpdated();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4F5BA8),
          content: Text('Profil dan foto berhasil diperbarui!'),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString().replaceAll('ApiException: ', '')),
          ),
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
                    // 1. AVATAR PROFIL KARYAWAN (Bisa diklik untuk ubah foto)
                    Center(
                      child: GestureDetector(
                        onTap: _pilihSumberFoto,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E9DC8), // Lavender-indigo pastel persis Figma
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F5BA8).withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: _fotoBaru != null
                                    ? Image.file(
                                        _fotoBaru!,
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                      )
                                    : (_fotoUrlAwal != null
                                        ? Image.network(
                                            _fotoUrlAwal!,
                                            width: 84,
                                            height: 84,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildInitialsBox(initials),
                                          )
                                        : _buildInitialsBox(initials)),
                              ),
                            ),
                            // Ikon Kamera di Sudut Kanan Bawah
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F5BA8),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.2),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pilihSumberFoto,
                      child: const Text(
                        'Ketuk untuk ubah foto',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F5BA8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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

  Widget _buildInitialsBox(String initials) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      color: const Color(0xFF8E9DC8),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
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
