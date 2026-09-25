import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class RiwayatAbsenScreen extends StatefulWidget {
  const RiwayatAbsenScreen({super.key});

  @override
  State<RiwayatAbsenScreen> createState() => _RiwayatAbsenScreenState();
}

class _RiwayatAbsenScreenState extends State<RiwayatAbsenScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.riwayatAbsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absen')),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = ApiService.riwayatAbsen()),
        child: FutureBuilder<List<dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? [];
            if (data.isEmpty) {
              return ListView(
                children: const [
                  Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada riwayat absen'))),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = data[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(item['tanggal'] ?? '-'),
                    subtitle: Text(
                      'Masuk: ${item['jam_masuk'] ?? '-'}   •   Pulang: ${item['jam_pulang'] ?? '-'}',
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
