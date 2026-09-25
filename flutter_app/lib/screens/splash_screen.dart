import 'package:flutter/material.dart';
import '../core/session.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'karyawan/dashboard_karyawan.dart';
import 'admin/dashboard_admin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _cekAlur();
  }

  // Mengikuti flow: START -> SPLASH -> sudah pernah lihat onboarding? -> LOGIN / ONBOARDING
  Future<void> _cekAlur() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final sudahOnboarding = await Session.sudahLihatOnboarding();
    if (!sudahOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final sudahLogin = await Session.sudahLogin();
    if (!sudahLogin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final role = await Session.getRole();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => role == 'admin' ? const DashboardAdmin() : const DashboardKaryawan(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 80, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Absensi App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
