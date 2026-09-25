import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class DataKaryawanScreen extends StatefulWidget {
  const DataKaryawanScreen({super.key});

  @override
  State<DataKaryawanScreen> createState() => _DataKaryawanScreenState();
}

class _DataKaryawanScreenState extends State<DataKaryawanScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() => setState(() => _future = ApiService.daftarKaryawan());

  Future<void> _hapus(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Karyawan'),
        content: const Text('Yakin ingin menghapus data karyawan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (konfirmasi != true) return;

    try {
      await ApiService.hapusKaryawan(id);
      _muat();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _bukaFormTambah() {
    showDialog(
      context: context,
      builder: (context) => _FormKaryawanDialog(onSukses: _muat),
    );
  }

  void _bukaFormEdit(Map<String, dynamic> karyawan) {
    showDialog(
      context: context,
      builder: (context) => _FormKaryawanDialog(karyawan: karyawan, onSukses: _muat),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Karyawan')),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormTambah,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _muat(),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? [];
            if (data.isEmpty) {
              return ListView(
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada data karyawan')))],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final k = data[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(k['nama'] ?? '-'),
                    subtitle: Text('${k['email'] ?? '-'}\n${k['jabatan'] ?? '-'}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _bukaFormEdit(k)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _hapus(k['id'])),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FormKaryawanDialog extends StatefulWidget {
  final Map<String, dynamic>? karyawan; // null = tambah baru
  final VoidCallback onSukses;
  const _FormKaryawanDialog({this.karyawan, required this.onSukses});

  @override
  State<_FormKaryawanDialog> createState() => _FormKaryawanDialogState();
}

class _FormKaryawanDialogState extends State<_FormKaryawanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _jabatanCtrl;
  late final TextEditingController _hpCtrl;
  bool _menyimpan = false;

  bool get _modeEdit => widget.karyawan != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.karyawan?['nama']);
    _emailCtrl = TextEditingController(text: widget.karyawan?['email']);
    _passwordCtrl = TextEditingController();
    _jabatanCtrl = TextEditingController(text: widget.karyawan?['jabatan']);
    _hpCtrl = TextEditingController(text: widget.karyawan?['no_hp']);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      if (_modeEdit) {
        await ApiService.updateKaryawan(widget.karyawan!['id'], {
          'nama': _namaCtrl.text.trim(),
          'jabatan': _jabatanCtrl.text.trim(),
          'no_hp': _hpCtrl.text.trim(),
        });
      } else {
        await ApiService.tambahKaryawan({
          'nama': _namaCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'jabatan': _jabatanCtrl.text.trim(),
          'no_hp': _hpCtrl.text.trim(),
        });
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSukses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_modeEdit ? 'Edit Karyawan' : 'Tambah Karyawan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              if (!_modeEdit) ...[
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
              ],
              TextFormField(controller: _jabatanCtrl, decoration: const InputDecoration(labelText: 'Jabatan')),
              TextFormField(controller: _hpCtrl, decoration: const InputDecoration(labelText: 'No. HP')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _menyimpan ? null : _simpan,
          child: _menyimpan
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
