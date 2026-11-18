import 'package:flutter/material.dart';

import '../services/api_services.dart';
import '../services/autentikasi_services.dart';
import 'cart_page.dart';

class ProductPages extends StatefulWidget {
  const ProductPages({super.key, required this.produk, required this.pengguna});

  final Map<String, dynamic> produk;
  final String pengguna;

  @override
  State<ProductPages> createState() => _ProductPagesState();
}

class _ProductPagesState extends State<ProductPages> {
  int _jumlah = 1;
  bool _menyimpan = false;
  late Future<Map<String, dynamic>> _detailProduk;

  @override
  void initState() {
    super.initState();
    _detailProduk = _ambilDetailProduk();
  }

  void _muatDetailProduk() {
    setState(() => _detailProduk = _ambilDetailProduk());
  }

  Future<Map<String, dynamic>> _ambilDetailProduk() {
    final id = widget.produk['id'];
    if (id is! int) {
      return Future.error(FormatException('ID produk tidak valid.'));
    }
    return LayananApi().ambilDetailProduk(id);
  }

  Future<void> _tambahKeKeranjang(Map<String, dynamic> produk) async {
    setState(() => _menyimpan = true);
    try {
      await AuthService.tambahProduk(widget.pengguna, produk, _jumlah);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil ditambahkan ke keranjang.'),
        ),
      );
      Navigator.of(context).pop();
    } on StateError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jumlahBarang =
        AuthService.jumlahBarang(widget.pengguna);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CartPage(pengguna: widget.pengguna),
                ),
              );
              if (mounted) setState(() {});
            },
            icon: Badge(
              isLabelVisible: jumlahBarang > 0,
              label: Text(jumlahBarang > 99 ? '99+' : '$jumlahBarang'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailProduk,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Detail produk belum bisa dimuat.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _muatDetailProduk,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _kontenProduk(snapshot.data!);
        },
      ),
    );
  }

  Widget _kontenProduk(Map<String, dynamic> produk) {
    final gambar = produk['image'] as String? ?? '';
    final kategori = (produk['category'] as String?) ?? 'Lainnya';
    final nama = (produk['title'] as String?) ?? 'Produk tanpa nama';
    final harga = (produk['price'] as num?)?.toDouble() ?? 0;
    final deskripsi =
        (produk['description'] as String?) ?? 'Tidak ada deskripsi.';
    final ratingData = produk['rating'];
    final rating = ratingData is Map
        ? (ratingData['rate'] as num?)?.toDouble() ?? 0
        : 0.0;
    final jumlahRating = ratingData is Map
        ? (ratingData['count'] as num?)?.toInt() ?? 0
        : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Container(
          height: 290,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: gambar.isEmpty
              ? const Icon(Icons.image_outlined, size: 80)
              : Image.network(
                  gambar,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.image_not_supported_outlined, size: 60),
                ),
        ),
        const SizedBox(height: 20),
        Text(
          kategori.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF287C68),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          nama,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF2AE45), size: 20),
            const SizedBox(width: 4),
            Text('${rating.toStringAsFixed(1)} ($jumlahRating ulasan)'),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '\$${harga.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF287C68),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          deskripsi,
          style: const TextStyle(height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 26),
        Row(
          // menampilkan jumlah produk yang akan ditambahkan ke keranjang
          children: [
            const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            IconButton.outlined(
              onPressed: _jumlah > 1 ? () => setState(() => _jumlah--) : null,
              icon: const Icon(Icons.remove),
            ),
            SizedBox(
              width: 42,
              child: Text('$_jumlah', textAlign: TextAlign.center),
            ),
            IconButton.outlined(
              onPressed: () => setState(() => _jumlah++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: _menyimpan ? null : () => _tambahKeKeranjang(produk),
            icon: _menyimpan
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add to Cart'),
          ),
        ),
      ],
    );
  }
}
