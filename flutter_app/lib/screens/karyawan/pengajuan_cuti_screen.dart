import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';

class PengajuanCutiScreen extends StatelessWidget {
  const PengajuanCutiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cuti'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pengajuan Cuti'),
              Tab(text: 'Informasi Cuti'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_FormPengajuanCuti(), _InformasiCuti()],
        ),
      ),
    );
  }
}

class _FormPengajuanCuti extends StatefulWidget {
  const _FormPengajuanCuti();

  @override
  State<_FormPengajuanCuti> createState() => _FormPengajuanCutiState();
}

class _FormPengajuanCutiState extends State<_FormPengajuanCuti> {
  final _formKey = GlobalKey<FormState>();
  final _alasanCtrl = TextEditingController();
  String _jenisCuti = 'Tahunan';
  DateTime? _mulai;
  DateTime? _selesai;
  bool _mengirim = false;

  final _jenisOptions = const ['Tahunan', 'Sakit', 'Izin', 'Lainnya'];

  Future<void> _pilihTanggal(bool isMulai) async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (tanggal != null) {
      setState(() => isMulai ? _mulai = tanggal : _selesai = tanggal);
    }
  }

  Future<void> _ajukan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mulai == null || _selesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
      );
      return;
    }

    setState(() => _mengirim = true);
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final hasil = await ApiService.ajukanCuti(
        jenisCuti: _jenisCuti,
        tanggalMulai: fmt.format(_mulai!),
        tanggalSelesai: fmt.format(_selesai!),
        alasan: _alasanCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hasil['message'] ?? 'Pengajuan cuti terkirim')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _alasanCtrl.clear();
        _mulai = null;
        _selesai = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _jenisCuti,
            decoration: const InputDecoration(labelText: 'Jenis Cuti', border: OutlineInputBorder()),
            items: _jenisOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _jenisCuti = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pilihTanggal(true),
                  child: Text(_mulai == null ? 'Tanggal Mulai' : fmt.format(_mulai!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pilihTanggal(false),
                  child: Text(_selesai == null ? 'Tanggal Selesai' : fmt.format(_selesai!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _alasanCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Alasan Cuti', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.isEmpty) ? 'Alasan wajib diisi' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mengirim ? null : _ajukan,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _mengirim
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Ajukan Cuti'),
          ),
        ],
      ),
    );
  }
}

class _InformasiCuti extends StatefulWidget {
  const _InformasiCuti();

  @override
  State<_InformasiCuti> createState() => _InformasiCutiState();
}

class _InformasiCutiState extends State<_InformasiCuti> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.informasiCutiSaya();
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() => _future = ApiService.informasiCutiSaya()),
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
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada pengajuan cuti')),
                ),
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
                  title: Text('${item['jenis_cuti']} — ${item['tanggal_mulai']} s/d ${item['tanggal_selesai']}'),
                  subtitle: Text(item['alasan'] ?? ''),
                  trailing: Chip(
                    label: Text(item['status'], style: const TextStyle(color: Colors.white)),
                    backgroundColor: _warnaStatus(item['status']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
