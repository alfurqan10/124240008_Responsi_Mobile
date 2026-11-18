import 'dart:convert';

import 'package:http/http.dart' as http;

class LayananApi {
  static const _alamat = 'https://fakestoreapi.com/products/';

  Future<List<Map<String, dynamic>>> ambilProduk() async {
    final response = await _ambil(Uri.parse(_alamat));
    return produkDariRespons(response.body);
  }

  Future<Map<String, dynamic>> ambilDetailProduk(int id) async {
    final response = await _ambil(Uri.parse('$_alamat$id'));
    return detailProdukDariRespons(response.body);
  }

  Future<http.Response> _ambil(Uri alamat) async {
    final response = await http
        .get(alamat)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Server produk merespons ${response.statusCode}.');
    }
    return response;
  }

  static List<Map<String, dynamic>> produkDariRespons(String body) {
    final data = jsonDecode(body) as List<dynamic>;
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Map<String, dynamic> detailProdukDariRespons(String body) {
    return Map<String, dynamic>.from(jsonDecode(body) as Map);
  }
}
