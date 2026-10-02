import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/constants.dart';
import '../core/session.dart';
import 'onboarding_screen.dart';
import 'karyawan/dashboard_karyawan.dart';
import 'admin/dashboard_admin.dart';
import 'components/selamat_datang_popup.dart';
import 'components/lupa_password_popup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorTeks;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorTeks = null;
    });

    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final password = _passwordCtrl.text;

      final res = await ApiService.login(email, password);
      final user = res['user'];
      await Session.simpanLogin(
        token: res['token'],
        role: user['role'],
        nama: user['nama'],
      );

      if (!mounted) return;
      final isAdmin = user['role'] == 'admin';
      final nama = (user['nama'] != null && user['nama'].toString().isNotEmpty)
          ? user['nama'].toString()
          : (isAdmin ? 'Super Admin' : 'Lilit Ransink');
      final roleTitle = isAdmin
          ? 'Administrator'
          : ((user['jabatan'] != null && user['jabatan'].toString().isNotEmpty)
              ? user['jabatan'].toString()
              : 'Teknisi Drone');

      bool navigated = false;
      await SelamatDatangPopup.show(
        context,
        nama: nama,
        roleTitle: roleTitle,
        onLanjutkan: () {
          navigated = true;
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => isAdmin
                  ? const DashboardAdmin()
                  : const DashboardKaryawan(),
            ),
            (route) => false,
          );
        },
      );

      if (!navigated && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => isAdmin
                ? const DashboardAdmin()
                : const DashboardKaryawan(),
          ),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorTeks = e.message);
    } catch (e) {
      debugPrint('Login gagal: $e');
      if (mounted) {
        setState(() {
          _errorTeks =
              'Tidak dapat terhubung ke server.\nPastikan backend sudah aktif (${AppConstants.baseUrl}).';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _isiAkunDemo(String email, String password) {
    setState(() {
      _emailCtrl.text = email;
      _passwordCtrl.text = password;
      _errorTeks = null;
    });
  }

  void _lupaPassword() {
    LupaPasswordPopup.show(
      context,
      initialEmail: _emailCtrl.text.trim(),
    );
  }

  Future<void> _ubahServerUrl() async {
    final serverCtrl = TextEditingController(text: AppConstants.baseUrl);
    bool testing = false;
    bool? testSuccess;
    String testMsg = '';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Pengaturan Server URL'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih preset sesuai perangkat pengujian:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('USB HP (127.0.0.1)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          serverCtrl.text = AppConstants.urlUsb;
                          testSuccess = null;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          serverCtrl.text = AppConstants.urlEmulator;
                          testSuccess = null;
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Localhost (Chrome)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          serverCtrl.text = AppConstants.urlLocalhost;
                          testSuccess = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: serverCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL Server Backend',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: testing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering, size: 16),
                      label: const Text('Tes Koneksi', style: TextStyle(fontSize: 12)),
                      onPressed: testing
                          ? null
                          : () async {
                              setDialogState(() {
                                testing = true;
                                testSuccess = null;
                              });
                              final ok = await ApiService.testConnection(serverCtrl.text);
                              setDialogState(() {
                                testing = false;
                                testSuccess = ok;
                                testMsg = ok
                                    ? '✓ Server Aktif & Terhubung!'
                                    : '✗ Gagal terhubung ke URL ini.';
                              });
                            },
                    ),
                    const SizedBox(width: 8),
                    if (testSuccess != null)
                      Expanded(
                        child: Text(
                          testMsg,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: testSuccess! ? Colors.green.shade700 : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final input = serverCtrl.text.trim();
                Navigator.pop(ctx);
                if (input.isNotEmpty) {
                  await AppConstants.setBaseUrl(input);
                  if (mounted) {
                    setState(() => _errorTeks = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL Server disimpan: ${AppConstants.baseUrl}')),
                    );
                  }
                }
              },
              child: const Text('Simpan & Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppConstants.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Banner Biru
          Container(
            width: double.infinity,
            color: primaryColor,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Action buttons bar kecil di sudut atas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Onboarding',
                          icon: Icon(Icons.help_outline, color: Colors.white.withValues(alpha: 0.8), size: 20),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Pengaturan Server',
                          icon: Icon(Icons.dns_outlined, color: Colors.white.withValues(alpha: 0.8), size: 20),
                          onPressed: _ubahServerUrl,
                        ),
                      ],
                    ),
                  ),

                  // Logo Icon Squircle Kuromi / Drone
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: 78,
                    height: 78,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),

                  // App Title
                  const Text(
                    'Absensiku',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    'Drone Agriculture Division',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 2. Formulir Login Putih
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Selamat Datang
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masuk untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Label EMAIL
                    const Text(
                      'EMAIL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 22),
                        hintText: 'anonymous@gmail.com',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: primaryColor, width: 1.6),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 18),

                    // Label PASSWORD
                    const Text(
                      'PASSWORD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B5563),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Input Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.shield_outlined, color: Color(0xFF9CA3AF), size: 22),
                        hintText: '*********',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, letterSpacing: 1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: primaryColor, width: 1.6),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 8),

                    // Link Lupa Password?
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _lupaPassword,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Lupa password?',
                            style: TextStyle(
                              color: Color(0xFF38438B),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Kotak Pesan Error (jika ada)
                    if (_errorTeks != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorTeks!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            if (_errorTeks!.contains('terhubung') || _errorTeks!.contains('server')) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.settings, size: 16),
                                  label: const Text('Ubah / Cek Pengaturan Server', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade900,
                                    side: BorderSide(color: Colors.red.shade300),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: _ubahServerUrl,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Divider Garis Pemisah
                    const Divider(color: Color(0xFFE5E7EB), thickness: 1.2),
                    const SizedBox(height: 12),

                    // Text Demo Login
                    const Center(
                      child: Text(
                        'Demo Login',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tombol Pilihan Karyawan & Admin
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                              foregroundColor: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () => _isiAkunDemo('karyawan@mail.com', 'karyawan123'),
                            child: const Text(
                              'Karyawan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                              foregroundColor: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () => _isiAkunDemo('admin@mail.com', 'admin123'),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
