import 'package:flutter/material.dart';
import 'absensi_screen.dart';
export 'status_sukses_screen.dart';

// Wrapper agar kompatibel dengan pemanggilan AbsenScreen sebelumnya
class AbsenScreen extends StatelessWidget {
  final bool masuk;
  const AbsenScreen({super.key, required this.masuk});

  @override
  Widget build(BuildContext context) {
    return AbsensiScreen(
      initialIsMasuk: masuk,
      isStandalone: true,
    );
  }
}
