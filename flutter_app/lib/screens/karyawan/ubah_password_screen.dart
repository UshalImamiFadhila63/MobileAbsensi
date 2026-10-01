import 'package:flutter/material.dart';

/// Halaman Ubah Password Karyawan
/// Dibuat 100% persis sesuai desain mockup Figma:
/// 1. Top bar: Warna biru indigo (#4F5BA8) dengan chevron kiri (<) & Judul "Ubah Password"
/// 2. Kartu 1: Input Password
///    - Password saat ini
///    - Password baru
///    - Konfirmasi password baru
/// 3. Kartu 2: Checklist Ketentuan Password
///    - "Password harus memenuhi:"
///    - ✓ Minimal 8 karakter
///    - ✓ Ada huruf besar dan kecil
///    - ✓ Ada angka atau simbol
/// 4. Tombol Bawah: "Simpan Password" (#4F5BA8)
class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _oldPassCtrl = TextEditingController(text: '••••••••');
  final _newPassCtrl = TextEditingController(text: '••••••••');
  final _confirmPassCtrl = TextEditingController(text: '••••••••');

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanPassword() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF4F5BA8),
        content: Text('Password berhasil diperbarui!'),
      ),
    );

    Navigator.of(context).pop(true);
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
                            onToggle: () => setState(() => _obscureOld = !_obscureOld),
                          ),
                          const SizedBox(height: 16),

                          // 2. Password baru
                          _buildPasswordField(
                            label: 'Password baru',
                            controller: _newPassCtrl,
                            obscure: _obscureNew,
                            onToggle: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          const SizedBox(height: 16),

                          // 3. Konfirmasi password baru
                          _buildPasswordField(
                            label: 'Konfirmasi password baru',
                            controller: _confirmPassCtrl,
                            obscure: _obscureConfirm,
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
                          _buildRequirementItem('Minimal 8 karakter'),
                          const SizedBox(height: 8),
                          _buildRequirementItem('Ada huruf besar dan kecil'),
                          const SizedBox(height: 8),
                          _buildRequirementItem('Ada angka atau simbol'),
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                    letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              InkWell(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Color(0xFF78A55A), // Hijau zaitun lembut persis Figma
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
