import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../../core/session.dart';
import '../login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getProfile();
      setState(() => _user = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                const CircleAvatar(radius: 44, child: Icon(Icons.person, size: 44)),
                const SizedBox(height: 12),
                Center(
                  child: Text(_user?['nama'] ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Center(child: Text(_user?['email'] ?? '-', style: const TextStyle(color: Colors.black54))),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(leading: const Icon(Icons.badge_outlined), title: const Text('Jabatan'), subtitle: Text(_user?['jabatan'] ?? '-')),
                      const Divider(height: 1),
                      ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('No. HP'), subtitle: Text(_user?['no_hp'] ?? '-')),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final berhasil = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!)),
                    );
                    if (berhasil == true) _muat();
                  },
                ),
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
