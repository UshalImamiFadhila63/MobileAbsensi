import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../../core/session.dart';
import '../login_screen.dart';
import 'components/notifikasi_sheet.dart';
import '../components/lupa_password_popup.dart';

class ProfileAdminScreen extends StatefulWidget {
  final bool showAppBar;
  final VoidCallback? onBukaRekapAbsensi;

  const ProfileAdminScreen({
    super.key,
    this.showAppBar = false,
    this.onBukaRekapAbsensi,
  });

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    try {
      final data = await ApiService.getProfile();
      if (!mounted) return;
      setState(() => _user = data);
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _bukaNotifikasi() async {
    await NotifikasiSheet.show(
      context,
      jumlahCutiMenunggu: 3,
      jumlahBelumAbsen: 5,
      jumlahTerlambat: 2,
      onTapBelumAbsen: () {
        widget.onBukaRekapAbsensi?.call();
      },
      onTapTerlambat: () {
        widget.onBukaRekapAbsensi?.call();
      },
    );
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
    if (konfirmasi != true) return;

    await Session.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = AppConstants.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Profil Admin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 24),
                      onPressed: _bukaNotifikasi,
                    ),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ],
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const CircleAvatar(
              radius: 44, child: Icon(Icons.admin_panel_settings, size: 44)),
          const SizedBox(height: 12),
          Center(
              child: Text(_user?['nama'] ?? '-',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
          Center(
              child: Text(_user?['email'] ?? '-',
                  style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F5BA8).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset, color: Color(0xFF4F5BA8)),
                  ),
                  title: const Text('Pop-up Lupa Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Tampilkan form reset password', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  onTap: () {
                    LupaPasswordPopup.show(
                      context,
                      initialEmail: _user?['email'],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
