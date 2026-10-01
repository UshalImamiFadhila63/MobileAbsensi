import 'package:flutter/material.dart';

/// Komponen pemilih bulan / periode (Month Picker)
/// Dibuat persis 100% sesuai screenshot komponen Figma yang dikirimkan user:
/// 1. Tombol Trigger:
///    - Inactive: Background abu-abu muda (#EAEBEF), border (#D1D5DB), teks hitam
///    - Active: Background biru (#4F5BA8), teks putih, shadow halus
/// 2. Stacked 3-Bulan (Agustus 2026, Juli 2026, Juni 2026):
///    - Wadah grouped dengan border radius melengkung
///    - Item aktif: Berlatar biru solid (#4F5BA8), teks putih tebal, sudut rounded 8, drop shadow
///    - Item nonaktif: Berlatar abu-abu (#EAEBEF), teks hitam
class MonthPickerGroupWidget extends StatefulWidget {
  final List<String> months;
  final String selectedMonth;
  final ValueChanged<String> onMonthChanged;

  static const List<String> defaultMonths = [
    'Januari 2026',
    'Februari 2026',
    'Maret 2026',
    'April 2026',
    'Mei 2026',
    'Juni 2026',
    'Juli 2026',
    'Agustus 2026',
    'September 2026',
    'Oktober 2026',
    'November 2026',
    'Desember 2026',
  ];

  const MonthPickerGroupWidget({
    super.key,
    this.months = defaultMonths,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthPickerGroupWidget> createState() => _MonthPickerGroupWidgetState();
}

class _MonthPickerGroupWidgetState extends State<MonthPickerGroupWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final idx = widget.months.indexOf(widget.selectedMonth);
    double initialOffset = 0.0;
    if (idx > 2) {
      initialOffset = ((idx - 2) * 39.0).clamp(0.0, 300.0);
    }
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175,
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEBEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          radius: const Radius.circular(4),
          thickness: 3.5,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.months.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                final isSelected = m == widget.selectedMonth;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (idx > 0 && !isSelected && widget.months[idx - 1] != widget.selectedMonth)
                      const Divider(height: 1, thickness: 1, color: Color(0xFFD1D5DB)),
                    GestureDetector(
                      onTap: () => widget.onMonthChanged(m),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        height: 38,
                        margin: isSelected
                            ? const EdgeInsets.symmetric(horizontal: 2, vertical: 2)
                            : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4F5BA8) : const Color(0xFFEAEBEF),
                          borderRadius: isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4F5BA8).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol Trigger Bulan yang saat diklik menampilkan Popup Menu persis Gambar 3
class MonthPickerButtonWithPopup extends StatefulWidget {
  final List<String> months;
  final String selectedMonth;
  final ValueChanged<String> onMonthChanged;

  const MonthPickerButtonWithPopup({
    super.key,
    this.months = MonthPickerGroupWidget.defaultMonths,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  State<MonthPickerButtonWithPopup> createState() => _MonthPickerButtonWithPopupState();
}

class _MonthPickerButtonWithPopupState extends State<MonthPickerButtonWithPopup> {
  final GlobalKey _buttonKey = GlobalKey();
  bool _isOpen = false;

  void _showDropdownPopup() {
    final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() => _isOpen = true);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            // Area tap luar untuk menutup
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Popup Stacked 3 Bulan persis sesuai Gambar 3
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: MonthPickerGroupWidget(
                    months: widget.months,
                    selectedMonth: widget.selectedMonth,
                    onMonthChanged: (newMonth) {
                      Navigator.pop(ctx);
                      widget.onMonthChanged(newMonth);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: _showDropdownPopup,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _isOpen ? const Color(0xFF4F5BA8) : const Color(0xFFEAEBEF),
          borderRadius: BorderRadius.circular(10),
          border: _isOpen ? null : Border.all(color: const Color(0xFFD1D5DB), width: 1),
          boxShadow: _isOpen
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F5BA8).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedMonth,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: _isOpen ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: _isOpen ? Colors.white : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}
