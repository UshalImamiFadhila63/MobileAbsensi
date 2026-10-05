import 'package:flutter/foundation.dart';

/// Event bus sederhana berbasis ValueNotifier
/// Digunakan untuk sinkronisasi state antar-tab (Home, Riwayat, Profil) tanpa restart app
class AppEvents {
  /// Dipicu ketika user mengubah data profil (nama, foto profil, dll)
  static final ValueNotifier<int> profileUpdated = ValueNotifier<int>(0);

  /// Dipicu ketika user melakukan absensi (absen masuk maupun absen pulang)
  static final ValueNotifier<int> attendanceUpdated = ValueNotifier<int>(0);

  static void notifyProfileUpdated() {
    profileUpdated.value++;
  }

  static void notifyAttendanceUpdated() {
    attendanceUpdated.value++;
  }
}
