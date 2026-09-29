import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'absensi_screen.dart';
import 'riwayat_absen_screen.dart';
import 'laporan_screen.dart';
import 'profile_screen.dart';
import '../../core/constants.dart';

class DashboardKaryawan extends StatefulWidget {
  const DashboardKaryawan({super.key});

  @override
  State<DashboardKaryawan> createState() => _DashboardKaryawanState();
}

class _DashboardKaryawanState extends State<DashboardKaryawan> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    AbsensiScreen(),
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
        indicatorColor: AppConstants.primaryColor.withValues(alpha: 0.15),
        backgroundColor: Colors.white,
        elevation: 4,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppConstants.primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: AppConstants.primaryColor),
            label: 'Absensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time),
            selectedIcon: Icon(Icons.access_time_filled, color: AppConstants.primaryColor),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description, color: AppConstants.primaryColor),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppConstants.primaryColor),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
