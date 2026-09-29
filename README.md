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

### Akun Default Demo (Siap Pakai)
- **Admin**: `admin@mail.com` | Password: `admin123` *(Akses ke Dashboard Admin & Manajemen Karyawan)*
- **Karyawan**: `karyawan@mail.com` | Password: `karyawan123` *(Akses ke Absensi Masuk/Pulang, Cuti, & Laporan)*

## Menjalankan Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

### Koneksi Backend & Mobile (Otomatis & Fleksibel)
Backend sudah otomatis menjalankan `adb reverse tcp:3000 tcp:3000` saat start jika ada HP Android terhubung via USB.

Di layar Login Flutter, juga tersedia tombol **Pengaturan Server URL** (icon DNS di pojok kanan atas atau saat tombol tes muncul):
- **HP Fisik via USB**: Gunakan preset `http://127.0.0.1:3000/api` (pastikan USB debugging aktif).
- **Android Emulator**: Gunakan preset `http://10.0.2.2:3000/api` (aplikasi juga memiliki fitur auto-fallback ke URL ini jika 127.0.0.1 gagal).
- **HP Fisik via WiFi**: Gunakan IP lokal laptop kamu (contoh `http://192.168.x.x:3000/api`).
- Terdapat tombol **"Tes Koneksi"** di dalam dialog untuk memastikan server terhubung sebelum login.

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
