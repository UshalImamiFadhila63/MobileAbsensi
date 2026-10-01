import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.prefKeyToken);
  }

  static Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _getToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- AUTH ----------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // 1. Coba dengan baseUrl saat ini
    try {
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 4));
      return _handle(res);
    } on ApiException {
      rethrow; // Password salah / validasi dari server
    } catch (_) {
      // 2. Jika gagal koneksi (misal beda network/emulator), coba fallback URL kandidat secara otomatis
      final fallbackUrls = [
        AppConstants.urlUsb,
        AppConstants.urlEmulator,
        AppConstants.urlLocalhost,
      ].where((u) => u != AppConstants.baseUrl).toList();

      for (final altUrl in fallbackUrls) {
        try {
          final res = await http.post(
            Uri.parse('$altUrl/auth/login'),
            headers: await _headers(),
            body: jsonEncode({'email': email, 'password': password}),
          ).timeout(const Duration(seconds: 3));
          
          // Jika sukses terhubung, perbarui baseUrl otomatis agar request selanjutnya lancar!
          await AppConstants.setBaseUrl(altUrl);
          return _handle(res);
        } on ApiException {
          await AppConstants.setBaseUrl(altUrl);
          rethrow;
        } catch (_) {
          continue;
        }
      }

      throw ApiException(
        'Tidak dapat terhubung ke server backend (${AppConstants.baseUrl}).\n'
        'Pastikan backend (node server.js) aktif.',
      );
    }
  }

  static Future<bool> testConnection(String url) async {
    try {
      String clean = url.trim();
      if (clean.endsWith('/')) clean = clean.substring(0, clean.length - 1);
      final rootUrl = clean.endsWith('/api') ? clean.substring(0, clean.length - 4) : clean;
      final res = await http.get(Uri.parse('$rootUrl/')).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> updateProfileTextOnly({
    required String nama,
    required String noHp,
    required String jabatan,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/auth/profile');
    final req = http.MultipartRequest('PUT', uri);
    req.headers.addAll(await _headers(json: false));
    req.fields['nama'] = nama;
    req.fields['no_hp'] = noHp;
    req.fields['jabatan'] = jabatan;

    final streamed = await req.send().timeout(const Duration(seconds: 20));
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/auth/profile'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  // ---------- ABSENSI ----------
  static Future<Map<String, dynamic>> statusHariIni() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/absensi/status-hari-ini'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> absenMasuk({
    required File foto,
    required double lat,
    required double lng,
  }) => _uploadAbsen('masuk', foto, lat, lng);

  static Future<Map<String, dynamic>> absenPulang({
    required File foto,
    required double lat,
    required double lng,
  }) => _uploadAbsen('pulang', foto, lat, lng);

  static Future<Map<String, dynamic>> _uploadAbsen(
    String jenis, File foto, double lat, double lng,
  ) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/absensi/$jenis');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _headers(json: false));
    req.fields['lat'] = lat.toString();
    req.fields['lng'] = lng.toString();
    req.files.add(await http.MultipartFile.fromPath('foto', foto.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<List<dynamic>> riwayatAbsen() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/absensi/riwayat'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  // ---------- CUTI ----------
  static Future<Map<String, dynamic>> ajukanCuti({
    required String jenisCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/cuti'),
      headers: await _headers(),
      body: jsonEncode({
        'jenis_cuti': jenisCuti,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'alasan': alasan,
      }),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<List<dynamic>> informasiCutiSaya() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/cuti/saya'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  static Future<List<dynamic>> daftarPengajuanCuti({String? status}) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/cuti').replace(
      queryParameters: status != null ? {'status': status} : null,
    );
    final res = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  static Future<Map<String, dynamic>> prosesCuti(int id, String status, {String? catatan}) async {
    final res = await http.put(
      Uri.parse('${AppConstants.baseUrl}/cuti/$id/proses'),
      headers: await _headers(),
      body: jsonEncode({'status': status, 'catatan_admin': catatan}),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  // ---------- LAPORAN ----------
  static Future<Map<String, dynamic>> submitLaporan({
    required String tanggal,
    required String judul,
    required String isiLaporan,
  }) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/laporan'),
      headers: await _headers(),
      body: jsonEncode({'tanggal': tanggal, 'judul': judul, 'isi_laporan': isiLaporan}),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<List<dynamic>> laporanSaya() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/laporan/saya'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  static Future<List<dynamic>> rekapLaporan() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/laporan/rekap'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  // ---------- KARYAWAN (ADMIN) ----------
  static Future<List<dynamic>> daftarKaryawan() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/karyawan'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  static Future<Map<String, dynamic>> tambahKaryawan(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${AppConstants.baseUrl}/karyawan'),
      headers: await _headers(),
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updateKaryawan(int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('${AppConstants.baseUrl}/karyawan/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<void> hapusKaryawan(int id) async {
    final res = await http.delete(
      Uri.parse('${AppConstants.baseUrl}/karyawan/$id'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    _handle(res);
  }

  static Future<List<dynamic>> rekapAbsensiAdmin() async {
    final res = await http.get(
      Uri.parse('${AppConstants.baseUrl}/absensi/rekap'),
      headers: await _headers(),
    ).timeout(const Duration(seconds: 15));
    return _handleList(res);
  }

  static dynamic _handle(http.Response res) {
    dynamic body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    } catch (_) {
      body = {'message': res.body.isNotEmpty ? res.body : 'Response dari server tidak valid'};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (Status ${res.statusCode})';
    throw ApiException(message);
  }

  static List<dynamic> _handleList(http.Response res) {
    dynamic body;
    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : [];
    } catch (_) {
      body = [];
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is List ? body : [];
    }
    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Terjadi kesalahan (Status ${res.statusCode})';
    throw ApiException(message);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
