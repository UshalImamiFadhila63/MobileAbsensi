import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hpCtrl;
  late final TextEditingController _jabatanCtrl;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.user['nama']);
    _hpCtrl = TextEditingController(text: widget.user['no_hp'] ?? '');
    _jabatanCtrl = TextEditingController(text: widget.user['jabatan'] ?? '');
  }

  Future<void> _simpan() async {
    setState(() => _menyimpan = true);
    try {
      // catatan: endpoint mendukung multipart utk upload foto profil,
      // di sini pakai multipart kosong (tanpa file) via PUT text field lewat http package terpisah bila perlu upload foto.
      await ApiService.updateProfileTextOnly(
        nama: _namaCtrl.text.trim(),
        noHp: _hpCtrl.text.trim(),
        jabatan: _jabatanCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _namaCtrl, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _hpCtrl, decoration: const InputDecoration(labelText: 'No. HP', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _jabatanCtrl, decoration: const InputDecoration(labelText: 'Jabatan', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _menyimpan ? null : _simpan,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _menyimpan
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
