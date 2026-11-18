import 'package:flutter/material.dart';

import '../services/autentikasi_services.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required this.pengguna});

  final String pengguna;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> get _barang =>
      AuthService.isiKeranjang(widget.pengguna);

  Future<void> _hapus(dynamic kunci) async {
    await AuthService.hapusProduk(widget.pengguna, kunci as String);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final barang = _barang;
    final total = barang.fold<double>(0, (jumlah, item) {
      final produk = item['produk'] as Map;
      return jumlah +
          ((produk['price'] as num).toDouble() *
              (item['jumlah'] as num).toInt());
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: barang.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 58,
                    color: Colors.black38,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keranjangmu masih kosong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  const Text('Yuk, pilih produk yang kamu suka.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: barang.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _kartuBarang(barang[index]),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE7EAE7))),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total belanja',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF287C68),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _kartuBarang(Map<String, dynamic> item) {
    final produk = item['produk'] as Map;
    final jumlah = (item['jumlah'] as num).toInt();
    final gambar = produk['image'] as String? ?? '';
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: gambar.isEmpty
                  ? const Icon(Icons.image_outlined)
                  : Image.network(
                      gambar,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk['title'] as String? ?? 'Produk',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$jumlah × \$${(produk['price'] as num).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus dari keranjang',
              onPressed: () => _hapus(item['kunci']),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
