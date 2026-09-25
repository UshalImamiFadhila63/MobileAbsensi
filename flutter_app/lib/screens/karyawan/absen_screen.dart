import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/api_service.dart';

// AMBIL FOTO + VALIDASI GPS (dipakai untuk absen masuk maupun pulang)
class AbsenScreen extends StatefulWidget {
  final bool masuk; // true = absen masuk, false = absen pulang
  const AbsenScreen({super.key, required this.masuk});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  File? _foto;
  Position? _posisi;
  bool _mencariLokasi = false;
  bool _mengirim = false;
  String? _pesan;

  Future<void> _ambilFoto() async {
    final picker = ImagePicker();
    final hasil = await picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
    if (hasil != null) {
      setState(() => _foto = File(hasil.path));
    }
  }

  Future<void> _ambilLokasi() async {
    setState(() {
      _mencariLokasi = true;
      _pesan = null;
    });
    try {
      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.deniedForever ||
          izin == LocationPermission.denied) {
        setState(() =>
            _pesan = 'Izin lokasi ditolak. Aktifkan izin lokasi untuk absen.');
        return;
      }

      final layananAktif = await Geolocator.isLocationServiceEnabled();
      if (!layananAktif) {
        setState(
            () => _pesan = 'Aktifkan GPS/lokasi perangkat terlebih dahulu.');
        return;
      }

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() => _posisi = posisi);
    } catch (e) {
      setState(() => _pesan = 'Gagal mengambil lokasi: $e');
    } finally {
      if (mounted) setState(() => _mencariLokasi = false);
    }
  }

  Future<void> _submit() async {
    if (_foto == null) {
      setState(() => _pesan = 'Ambil foto terlebih dahulu');
      return;
    }
    if (_posisi == null) {
      setState(() => _pesan = 'Ambil lokasi terlebih dahulu');
      return;
    }

    setState(() {
      _mengirim = true;
      _pesan = null;
    });

    try {
      final hasil = widget.masuk
          ? await ApiService.absenMasuk(
              foto: _foto!, lat: _posisi!.latitude, lng: _posisi!.longitude)
          : await ApiService.absenPulang(
              foto: _foto!, lat: _posisi!.latitude, lng: _posisi!.longitude);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hasil['message'] ?? 'Absen berhasil')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _pesan = e.toString());
    } finally {
      if (mounted) setState(() => _mengirim = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.masuk ? 'Absen Masuk' : 'Absen Pulang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _foto == null
                  ? const Center(
                      child:
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_foto!,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _ambilFoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(_foto == null ? 'Ambil Foto' : 'Ambil Ulang Foto'),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                  _posisi != null ? Icons.location_on : Icons.location_off,
                  color: _posisi != null ? Colors.green : Colors.grey),
              title: Text(_posisi != null
                  ? 'Lokasi: ${_posisi!.latitude.toStringAsFixed(5)}, ${_posisi!.longitude.toStringAsFixed(5)}'
                  : 'Lokasi belum diambil'),
              trailing: _mencariLokasi
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _ambilLokasi,
                      child: const Text('Validasi GPS')),
            ),
          ),
          if (_pesan != null) ...[
            const SizedBox(height: 12),
            Text(_pesan!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _mengirim ? null : _submit,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _mengirim
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(widget.masuk
                    ? 'Submit Absen Masuk'
                    : 'Submit Absen Pulang'),
          ),
        ],
      ),
    );
  }
}
