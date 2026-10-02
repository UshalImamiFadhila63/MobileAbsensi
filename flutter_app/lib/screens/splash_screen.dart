import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/session.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'admin/dashboard_admin.dart';
import 'karyawan/dashboard_karyawan.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
    _cekAlur();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Buka aplikasi -> Splash -> Cek Session Login / Onboarding
  Future<void> _cekAlur() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final isLoggedIn = await Session.sudahLogin();
    if (isLoggedIn) {
      final role = await Session.getRole();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? const DashboardAdmin()
              : const DashboardKaryawan(),
        ),
      );
      return;
    }

    final seenOnboarding = await Session.sudahLihatOnboarding();
    if (!mounted) return;

    if (seenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8FAFD),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final size = MediaQuery.of(context).size;
    final logoWidth = (size.width * 0.81).clamp(240.0, 340.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: CustomPaint(
        painter: const _SplashBackgroundPainter(),
        child: SizedBox.expand(
          child: Align(
            alignment: const Alignment(0, -0.10),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/pt_dunia_maya_logo_3x.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  const _SplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Solid canvas background
    final bgPaint = Paint()..color = const Color(0xFFF8FAFD);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Top-left soft blue organic curve
    // Rx ~ 0.316 * width, Ry ~ 0.166 * height
    final tlPaint = Paint()..color = const Color(0xFFE3EEFD);
    final tlRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.632,
      height: size.height * 0.332,
    );
    canvas.drawOval(tlRect, tlPaint);

    // 3. Bottom-right soft peach/pink organic curve
    // Rx ~ 0.420 * width, Ry ~ 0.216 * height
    final brPaint = Paint()..color = const Color(0xFFF2E8EB);
    final brRect = Rect.fromCenter(
      center: Offset(size.width, size.height),
      width: size.width * 0.840,
      height: size.height * 0.432,
    );
    canvas.drawOval(brRect, brPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
