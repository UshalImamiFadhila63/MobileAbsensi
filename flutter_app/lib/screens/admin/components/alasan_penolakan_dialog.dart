import 'package:flutter/material.dart';

/// Dialog konfirmasi penolakan dengan alasan penolakan
/// Sesuai dengan desain mockup (Alasan Penolakan)
class AlasanPenolakanDialog extends StatefulWidget {
  final String? initialReason;
  final String title;
  final String label;
  final String hintText;
  final String confirmText;
  final String cancelText;
  final Future<void> Function(String alasan)? onConfirm;

  const AlasanPenolakanDialog({
    super.key,
    this.initialReason,
    this.title = 'Alasan Penolakan',
    this.label = 'Alasan Penolakan',
    this.hintText = 'Tuliskan alasan penolakan cuti...',
    this.confirmText = 'Konfirmasi Penolakan',
    this.cancelText = 'Batal',
    this.onConfirm,
  });

  /// Helper statis untuk menampilkan dialog
  static Future<String?> show(
    BuildContext context, {
    String? initialReason,
    String title = 'Alasan Penolakan',
    String label = 'Alasan Penolakan',
    String hintText = 'Tuliskan alasan penolakan cuti...',
    String confirmText = 'Konfirmasi Penolakan',
    String cancelText = 'Batal',
    Future<void> Function(String alasan)? onConfirm,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlasanPenolakanDialog(
        initialReason: initialReason,
        title: title,
        label: label,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AlasanPenolakanDialog> createState() => _AlasanPenolakanDialogState();
}

class _AlasanPenolakanDialogState extends State<AlasanPenolakanDialog> {
  late final TextEditingController _controller;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReason);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Alasan penolakan tidak boleh kosong');
      return;
    }

    if (widget.onConfirm != null) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
      try {
        await widget.onConfirm!(text);
        if (!mounted) return;
        Navigator.of(context).pop(text);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    } else {
      Navigator.of(context).pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 360),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Judul & Tombol Close 'X'
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(null),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Label Alasan Penolakan
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),

              // Kotak Input Multiline
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 3,
                  maxLines: 4,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() => _errorMessage = null);
                    }
                  },
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13.5,
                      fontWeight: FontWeight.normal,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4F5BA8), width: 1.6),
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Tombol Konfirmasi Penolakan (Merah)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626), // Merah sesuai gambar
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.confirmText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tombol Batal (Putih dengan border tipis dan bayangan halus)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.cancelText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
