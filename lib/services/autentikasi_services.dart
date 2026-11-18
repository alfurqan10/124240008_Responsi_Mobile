import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _loggedInKey = 'is_logged_in';
  static String? _penggunaAktif;
  static final Map<String, List<Map<String, dynamic>>> _keranjangPengguna = {};

  static String? get penggunaAktif => _penggunaAktif;

  static Future<String?> getSavedEmail() async {
    final preferences = await SharedPreferences.getInstance();
    if (!(preferences.getBool(_loggedInKey) ?? false)) return null;
    return preferences.getString(_emailKey);
  }

  static Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Email dan password harus diisi.');
    }
    final preferences = await SharedPreferences.getInstance();
    final pengguna = email.trim();
    await preferences.setString(_emailKey, pengguna);
    await preferences.setBool(_loggedInKey, true);
    _penggunaAktif = pengguna;
    await _muatKeranjang(pengguna);
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_emailKey);
    await preferences.remove(_loggedInKey);
    _penggunaAktif = null;
  }

  static Future<void> tambahProduk(
    String pengguna,
    Map<String, dynamic> produk,
    int jumlah,
  ) async {
    if (jumlah <= 0) {
      throw ArgumentError.value(jumlah, 'jumlah', 'Harus lebih dari 0.');
    }
    final id = produk['id'];
    if (id == null) {
      throw ArgumentError('Produk harus memiliki ID.');
    }

    final keranjang = await _muatKeranjang(pengguna);
    final kunci = id.toString();
    final index = keranjang.indexWhere((item) => item['kunci'] == kunci);
    if (index == -1) {
      keranjang.add({
        'kunci': kunci,
        'produk': Map<String, dynamic>.from(produk),
        'jumlah': jumlah,
      });
    } else {
      final item = keranjang[index];
      item['jumlah'] = (item['jumlah'] as int) + jumlah;
    }
    await _simpanKeranjang(pengguna, keranjang);
  }

  static int jumlahBarang(String pengguna) {
    final keranjang = _keranjangPengguna[_kunciPengguna(pengguna)] ?? const [];
    return keranjang.fold<int>(
      0,
      (total, item) => total + (item['jumlah'] as int),
    );
  }

  static Future<void> hapusProduk(String pengguna, String kunci) async {
    final keranjang = await _muatKeranjang(pengguna);
    keranjang.removeWhere((item) => item['kunci'] == kunci);
    await _simpanKeranjang(pengguna, keranjang);
  }

  static List<Map<String, dynamic>> isiKeranjang(String pengguna) {
    final keranjang = _keranjangPengguna[_kunciPengguna(pengguna)] ?? const [];
    return keranjang.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> mulai() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_loggedInKey) ?? false) {
      _penggunaAktif = preferences.getString(_emailKey);
      if (_penggunaAktif != null) {
        await _muatKeranjang(_penggunaAktif!);
      }
    } else {
      _penggunaAktif = null;
    }
  }

  static String _kunciPengguna(String pengguna) =>
      pengguna.trim().toLowerCase();

  static String _kunciPenyimpanan(String pengguna) =>
      'cart_${_kunciPengguna(pengguna)}';

  static Future<List<Map<String, dynamic>>> _muatKeranjang(
    String pengguna,
  ) async {
    final kunciPengguna = _kunciPengguna(pengguna);
    final keranjangTersimpan = _keranjangPengguna[kunciPengguna];
    if (keranjangTersimpan != null) return keranjangTersimpan;

    final preferences = await SharedPreferences.getInstance();
    final isi = preferences.getString(_kunciPenyimpanan(pengguna));
    if (isi == null) {
      return _keranjangPengguna[kunciPengguna] = [];
    }

    final data = jsonDecode(isi) as List<dynamic>;
    final keranjang = data
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    _keranjangPengguna[kunciPengguna] = keranjang;
    return keranjang;
  }

  static Future<void> _simpanKeranjang(
    String pengguna,
    List<Map<String, dynamic>> keranjang,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _kunciPenyimpanan(pengguna),
      jsonEncode(keranjang),
    );
    _keranjangPengguna[_kunciPengguna(pengguna)] = keranjang;
  }
}
