import 'package:flutter/material.dart';
import 'package:responsi/services/autentikasi_services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.pengguna,
    required this.onKeluar,
  });

  final String pengguna;
  final Future<void> Function() onKeluar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFFDCEFE8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Text(
                  pengguna.isEmpty ? '?' : pengguna[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Color(0xFF287C68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                pengguna,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jumlah Barang yang dikeranjang : ${AuthService.jumlahBarang(pengguna)}',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: onKeluar,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
