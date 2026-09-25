import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'pengajuan_cuti_screen.dart';
import 'riwayat_absen_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';

class DashboardKaryawan extends StatefulWidget {
  const DashboardKaryawan({super.key});

  @override
  State<DashboardKaryawan> createState() => _DashboardKaryawanState();
}

class _DashboardKaryawanState extends State<DashboardKaryawan> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    PengajuanCutiScreen(),
    RiwayatAbsenScreen(),
    LaporanScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Cuti'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history_edu), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: 'Laporan'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
