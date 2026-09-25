import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class PersetujuanCutiScreen extends StatefulWidget {
  const PersetujuanCutiScreen({super.key});

  @override
  State<PersetujuanCutiScreen> createState() => _PersetujuanCutiScreenState();
}

class _PersetujuanCutiScreenState extends State<PersetujuanCutiScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() => setState(() => _future = ApiService.daftarPengajuanCuti(status: 'menunggu'));

  Future<void> _lihatDetail(Map<String, dynamic> item) async {
    final user = item['User'] ?? {};
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['nama'] ?? '-'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis: ${item['jenis_cuti']}'),
            Text('Tanggal: ${item['tanggal_mulai']} s/d ${item['tanggal_selesai']}'),
            const SizedBox(height: 8),
            Text('Alasan: ${item['alasan']}'),
            if (item['lampiran'] != null) ...[
              const SizedBox(height: 8),
              Text('Lampiran: ${item['lampiran']}', style: const TextStyle(color: Colors.blue)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _proses(item['id'], 'ditolak');
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _proses(item['id'], 'diterima');
            },
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
  }

  Future<void> _proses(int id, String status) async {
    try {
      final hasil = await ApiService.prosesCuti(id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hasil['message'] ?? 'Berhasil diproses')));
      _muat();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persetujuan Cuti')),
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
                children: const [Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Tidak ada pengajuan cuti yang menunggu')))],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = data[i];
                final user = item['User'] ?? {};
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['nama'] ?? '-'),
                    subtitle: Text('${item['jenis_cuti']} — ${item['tanggal_mulai']} s/d ${item['tanggal_selesai']}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _lihatDetail(item),
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
