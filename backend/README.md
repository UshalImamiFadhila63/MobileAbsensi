# Aplikasi Absensi Karyawan (Flutter + Node.js)

Struktur project ini mengikuti alur (user flow) yang kamu kirim: splash → onboarding →
login → dashboard (karyawan / admin) → absen masuk/pulang (foto + validasi GPS),
pengajuan & persetujuan cuti, laporan, dan data karyawan (CRUD).

## Struktur folder

```
backend/        # REST API - Node.js, Express, Sequelize (MySQL)
flutter_app/    # Aplikasi mobile - Flutter
```

## Menjalankan Backend

```bash
cd backend
cp .env.example .env      # sesuaikan DB_*, JWT_SECRET, dan koordinat kantor (OFFICE_LAT/LNG)
npm install
npm run dev                # atau: npm start
```

Buat database MySQL kosong dengan nama sesuai `DB_NAME` di `.env` — tabel akan
otomatis dibuat oleh Sequelize saat server pertama kali jalan (`sequelize.sync()`).

Untuk akun awal (karena belum ada endpoint register), insert manual 1 user admin
ke tabel `users` (password di-hash pakai bcrypt), atau tambahkan sementara
endpoint/script seed sesuai kebutuhan.

## Menjalankan Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

Sebelum run, sesuaikan `lib/core/constants.dart`:
- `baseUrl` → alamat backend kamu (`10.0.2.2` untuk emulator Android yang backend-nya
  jalan di localhost, atau IP lokal laptop kalau tes di HP fisik dalam satu jaringan wifi).

App butuh izin **Kamera** dan **Lokasi**. Tambahkan permission berikut:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan kamera untuk absen</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan lokasi untuk validasi absen</string>
```

## Yang sudah diimplementasikan (sesuai flow)

**Karyawan:** splash → onboarding → login → dashboard (Home, Pengajuan Cuti,
Riwayat Absen, Laporan, Profile) → absen masuk/pulang (foto + validasi GPS radius
kantor) → form pengajuan cuti + informasi status cuti → form laporan → edit
profile → logout.

**Admin:** login → dashboard (Data Karyawan, Rekap Absensi, Persetujuan Cuti,
Profile) → CRUD data karyawan → lihat rekap absensi semua karyawan → lihat daftar
pengajuan cuti, periksa detail, setujui/tolak → logout.

## Yang belum / perlu kamu lanjutkan

- UI masih polos (Material default) — tinggal disesuaikan begitu desain Figma final
  selesai (warna, font, komponen custom, dsb).
- Belum ada halaman "Rekap Laporan" khusus di sisi admin (endpoint backend-nya
  sudah ada: `GET /api/laporan/rekap`), tinggal dibuatkan screen-nya.
- Belum ada endpoint register/seed admin pertama — perlu ditambahkan atau insert manual.
- Validasi radius kantor pakai satu titik koordinat tunggal (`OFFICE_LAT/LNG`) —
  kalau ada banyak cabang kantor, perlu disesuaikan modelnya.
