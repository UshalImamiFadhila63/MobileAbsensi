import 'package:flutter/material.dart';
import '../../core/api_service.dart';

/// Halaman Ubah Password Karyawan
/// Dibuat 100% persis sesuai desain mockup Figma:
/// 1. Top bar: Warna biru indigo (#4F5BA8) dengan chevron kiri (<) & Judul "Ubah Password"
/// 2. Kartu 1: Input Password
///    - Password saat ini (dengan toggle mata intip)
///    - Password baru (dengan toggle mata intip)
///    - Konfirmasi password baru (dengan toggle mata intip)
/// 3. Kartu 2: Checklist Ketentuan Password (Interaktif Real-time)
///    - Minimal 8 karakter
///    - Ada huruf besar dan kecil
///    - Ada angka atau simbol
/// 4. Validasi Lengkap & Pop Up Error/Warning jika konfirmasi password tidak sama
/// 5. Tombol Bawah: "Simpan Password" (#4F5BA8) dengan integrasi API backend
class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Listener untuk memperbarui checklist ketentuan password secara real-time
    _newPassCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool get _hasMin8Chars => _newPassCtrl.text.length >= 8;
  bool get _hasLetters => RegExp(r'[a-zA-Z]').hasMatch(_newPassCtrl.text);
  bool get _hasDigitOrSymbol =>
      RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]').hasMatch(_newPassCtrl.text);

  /// Menampilkan popup dialog peringatan / error
  void _showWarningDialog({
    required String title,
    required String message,
    bool isError = true,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                color: isError ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4B5563),
            height: 1.4,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F5BA8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simpanPassword() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (oldPass.isEmpty) {
      _showWarningDialog(
        title: 'Input Belum Lengkap',
        message: 'Silakan masukkan password saat ini terlebih dahulu.',
      );
      return;
    }

    if (newPass.isEmpty) {
      _showWarningDialog(
        title: 'Input Belum Lengkap',
        message: 'Silakan masukkan password baru yang ingin digunakan.',
      );
      return;
    }

    if (confirmPass.isEmpty) {
      _showWarningDialog(
        title: 'Input Belum Lengkap',
        message: 'Silakan ketik ulang password baru pada kolom konfirmasi password.',
      );
      return;
    }

    // POP UP VALIDASI: Password Baru dan Konfirmasi Tidak Sama
    if (newPass != confirmPass) {
      _showWarningDialog(
        title: 'Password Tidak Sama',
        message: 'Konfirmasi password baru tidak cocok dengan password baru. Mohon periksa kembali ketikan Anda.',
      );
      return;
    }

    // Validasi ketentuan password
    if (!_hasMin8Chars) {
      _showWarningDialog(
        title: 'Ketentuan Belum Terpenuhi',
        message: 'Password baru minimal harus memiliki panjang 8 karakter.',
      );
      return;
    }

    if (!_hasLetters) {
      _showWarningDialog(
        title: 'Ketentuan Belum Terpenuhi',
        message: 'Password baru harus mengandung setidaknya huruf alfabet.',
      );
      return;
    }

    if (!_hasDigitOrSymbol) {
      _showWarningDialog(
        title: 'Ketentuan Belum Terpenuhi',
        message: 'Password baru harus mengandung minimal 1 angka atau simbol unik.',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.ubahPassword(
        passwordLama: oldPass,
        passwordBaru: newPass,
      );

      if (!mounted) return;

      // Popup Sukses
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF16A34A), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Berhasil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Password Anda telah berhasil diperbarui! Silakan gunakan password baru ini pada login berikutnya.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F5BA8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showWarningDialog(
        title: 'Gagal Ubah Password',
        message: e.toString().replaceAll('ApiException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
          'Ubah Password',
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
                    // KARTU 1: INPUT PASSWORD
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
                          // 1. Password saat ini
                          _buildPasswordField(
                            label: 'Password saat ini',
                            controller: _oldPassCtrl,
                            obscure: _obscureOld,
                            hintText: 'Masukkan password saat ini',
                            onToggle: () => setState(() => _obscureOld = !_obscureOld),
                          ),
                          const SizedBox(height: 16),

                          // 2. Password baru
                          _buildPasswordField(
                            label: 'Password baru',
                            controller: _newPassCtrl,
                            obscure: _obscureNew,
                            hintText: 'Masukkan password baru minimal 8 karakter',
                            onToggle: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          const SizedBox(height: 16),

                          // 3. Konfirmasi password baru
                          _buildPasswordField(
                            label: 'Konfirmasi password baru',
                            controller: _confirmPassCtrl,
                            obscure: _obscureConfirm,
                            hintText: 'Ulangi password baru Anda',
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // KARTU 2: CHECKLIST KETENTUAN PASSWORD
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
                          const Text(
                            'Password harus memenuhi:',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem('Minimal 8 karakter', _hasMin8Chars),
                          const SizedBox(height: 8),
                          _buildRequirementItem('Ada huruf (besar atau kecil)', _hasLetters),
                          const SizedBox(height: 8),
                          _buildRequirementItem('Ada angka atau simbol', _hasDigitOrSymbol),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL BAWAH: "Simpan Password"
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
                  onPressed: _saving ? null : _simpanPassword,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Password',
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String hintText,
  }) {
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  obscuringCharacter: '•',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: const Color(0xFF111827),
                    letterSpacing: obscure ? 2.5 : 0,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: obscure ? const Color(0xFF9CA3AF) : const Color(0xFF4F5BA8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isFulfilled) {
    return Row(
      children: [
        Icon(
          isFulfilled ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isFulfilled
              ? const Color(0xFF16A34A) // Hijau jika terpenuhi
              : const Color(0xFF9CA3AF), // Abu-abu jika belum
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isFulfilled ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            fontWeight: isFulfilled ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
