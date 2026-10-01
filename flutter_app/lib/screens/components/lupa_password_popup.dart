import 'package:flutter/material.dart';

/// Modal Popup "Lupa Password"
/// Dibuat 100% persis sesuai desain Figma yang dikirimkan user:
/// - Judul "Lupa Password" dengan tombol silang (x) di kanan atas
/// - Teks instruksi: "Masukkan email Anda dan kami akan mengirimkan instruksi reset password."
/// - Label: "EMAIL"
/// - Input email dengan ikon profil/avatar & placeholder "email@drone.id"
/// - Tombol: "Kirim Email Reset" berwarna ungu navy (#4F5BA8)
class LupaPasswordPopup extends StatefulWidget {
  final String? initialEmail;
  final ValueChanged<String>? onSubmit;

  const LupaPasswordPopup({
    super.key,
    this.initialEmail,
    this.onSubmit,
  });

  /// Helper untuk menampilkan popup Lupa Password
  static Future<void> show(
    BuildContext context, {
    String? initialEmail,
    ValueChanged<String>? onSubmit,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
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
            child: LupaPasswordPopup(
              initialEmail: initialEmail,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<LupaPasswordPopup> createState() => _LupaPasswordPopupState();
}

class _LupaPasswordPopupState extends State<LupaPasswordPopup> {
  late final TextEditingController _emailCtrl;
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _kirimReset() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Silakan masukkan email Anda');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pop();

      if (widget.onSubmit != null) {
        widget.onSubmit!(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('Instruksi reset password telah dikirim ke $email'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: "Lupa Password" & Tombol 'X'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lupa Password',
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
          const SizedBox(height: 14),

          // 2. Deskripsi Instruksi
          const Text(
            'Masukkan email Anda dan kami akan mengirimkan instruksi reset password.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Label "EMAIL"
          const Text(
            'EMAIL',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),

          // 4. Input Field Email
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'email@drone.id',
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.person,
                  color: Color(0xFFBDBDBD),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4F5BA8), width: 1.5),
              ),
              errorText: _errorText,
            ),
          ),
          const SizedBox(height: 18),

          // 5. Tombol "Kirim Email Reset"
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
              onPressed: _loading ? null : _kirimReset,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Kirim Email Reset',
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
