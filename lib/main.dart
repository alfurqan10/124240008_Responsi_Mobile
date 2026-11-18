import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/autentikasi_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await AuthService.mulai();
  runApp(const AplikasiToko());
}

class AplikasiToko extends StatefulWidget {
  const AplikasiToko({super.key});

  @override
  State<AplikasiToko> createState() => _AplikasiTokoState();
}

class _AplikasiTokoState extends State<AplikasiToko> {
  String? _pengguna = AuthService.penggunaAktif;

  void _masuk(String nama) {
    setState(() => _pengguna = nama);
  }

  Future<void> _keluar() async {
    await AuthService.logout();
    if (mounted) setState(() => _pengguna = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alexshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF287C68),
          surface: const Color(0xFFF7F8F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F5),
          foregroundColor: Color(0xFF20352F),
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: _pengguna == null
          ? LoginPage(onLogin: _masuk)
          : Homepage(
              pengguna: _pengguna!,
              onKeluar: _keluar,
              onLogout: _keluar,
            ),
    );
  }
}
