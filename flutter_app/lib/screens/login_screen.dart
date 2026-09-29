import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/constants.dart';
import '../core/session.dart';
import 'onboarding_screen.dart';
import 'karyawan/dashboard_karyawan.dart';
import 'admin/dashboard_admin.dart';

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => user['role'] == 'admin'
              ? const DashboardAdmin()
              : const DashboardKaryawan(),
        ),
        (route) => false,
      );
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
                      label: const Text('WiFi LAN (192.168.22.169)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          serverCtrl.text = 'http://192.168.22.169:3000/api';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Lihat Onboarding',
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Pengaturan Server API',
            icon: const Icon(Icons.dns_outlined),
            onPressed: _ubahServerUrl,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fingerprint, size: 72, color: AppConstants.primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Masuk ke Akun',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masukkan email dan password untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Password wajib diisi'
                        : null,
                  ),
                  if (_errorTeks != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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
                        : const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilihan Akun Demo (Klik untuk isi cepat):',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Admin'),
                        onPressed: () => _isiAkunDemo('admin@mail.com', 'admin123'),
                      ),
                      const SizedBox(width: 12),
                      ActionChip(
                        avatar: const Icon(Icons.badge, size: 16),
                        label: const Text('Karyawan'),
                        onPressed: () => _isiAkunDemo('karyawan@mail.com', 'karyawan123'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

