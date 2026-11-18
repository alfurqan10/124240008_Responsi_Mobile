import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/services/api_services.dart';

void main() {
  test('produkDariRespons membaca daftar produk Fake Store API', () {
    final produk = LayananApi.produkDariRespons('''
      [
        {
          "id": 1,
          "title": "Fjallraven Backpack",
          "price": 109.95,
          "category": "men's clothing",
          "image": "https://example.com/product.jpg",
          "rating": {"rate": 3.9, "count": 120}
        }
      ]
    ''');

    expect(produk, hasLength(1));
    expect(produk.single['title'], 'Fjallraven Backpack');
    expect(produk.single['image'], 'https://example.com/product.jpg');
    expect(produk.single['rating']['rate'], 3.9);
  });

  test('detailProdukDariRespons membaca satu produk Fake Store API', () {
    final produk = LayananApi.detailProdukDariRespons('''
      {
        "id": 1,
        "title": "Fjallraven Backpack",
        "price": 109.95,
        "image": "https://example.com/product.jpg"
      }
    ''');

    expect(produk['id'], 1);
    expect(produk['title'], 'Fjallraven Backpack');
  });
}
