import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';

import 'core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await AppConstants.initBaseUrl();
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppConstants.primaryColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
