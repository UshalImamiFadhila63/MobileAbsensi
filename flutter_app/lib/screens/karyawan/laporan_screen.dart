import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  DateTime _tanggal = DateTime.now();
  bool _mengirim = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _mengirim = true);
    try {
      final hasil = await ApiService.submitLaporan(
        tanggal: DateFormat('yyyy-MM-dd').format(_tanggal),
        judul: _judulCtrl.text.trim(),
        isiLaporan: _isiCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hasil['message'] ?? 'Laporan terkirim')),
      );
      _judulCtrl.clear();
      _isiCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(DateFormat('dd MMM yyyy').format(_tanggal)),
              onPressed: () async {
                final t = await showDatePicker(
                  context: context,
                  initialDate: _tanggal,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (t != null) setState(() => _tanggal = t);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(labelText: 'Judul Laporan', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Isi Laporan', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Isi laporan wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _mengirim ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _mengirim
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}
