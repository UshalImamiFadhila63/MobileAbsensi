class AppConstants {
  // Untuk testing HP via USB, pakai adb reverse tcp:3000 tcp:3000
  // lalu akses backend dari HP lewat localhost:3000
  static const String baseUrl = 'http://localhost:3000/api';

  static const String prefKeyToken = 'token';
  static const String prefKeyRole = 'role';
  static const String prefKeyNama = 'nama';
  static const String prefKeyOnboardingSeen = 'onboarding_seen';
}
