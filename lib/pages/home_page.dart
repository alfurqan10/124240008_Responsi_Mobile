import 'package:flutter/material.dart';
import 'package:responsi/pages/product_pages.dart';

import '../services/api_services.dart';
import '../services/autentikasi_services.dart';
import 'cart_page.dart';
import 'profile_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    super.key,
    required this.pengguna,
    required this.onKeluar,
    required Future<void> Function() onLogout,
  });

  final String pengguna;
  final Future<void> Function() onKeluar;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _tabAktif = 0;
  late int _jumlahBarang;
  late Future<List<Map<String, dynamic>>> _produk;

  @override
  void initState() {
    super.initState();
    _produk = LayananApi().ambilProduk();
    _jumlahBarang = AuthService.jumlahBarang(widget.pengguna);
  }

  void _muatUlang() {
    setState(() => _produk = LayananApi().ambilProduk());
  }

  void _perbaruiJumlahBarang() {
    if (!mounted) return;
    setState(() {
      _jumlahBarang = AuthService.jumlahBarang(widget.pengguna);
    });
  }

  Future<void> _bukaKeranjang() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartPage(pengguna: widget.pengguna),
      ),
    );
    _perbaruiJumlahBarang();
  }

  Future<void> _bukaProduk(Map<String, dynamic> produk) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductPages(produk: produk, pengguna: widget.pengguna),
      ),
    );
    _perbaruiJumlahBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabAktif == 0 ? 'alexshop' : 'Profil'),
        actions: [
          if (_tabAktif == 0)
            IconButton(
              tooltip: 'Keranjang',
              onPressed: _bukaKeranjang,
              icon: Badge(
                isLabelVisible: _jumlahBarang > 0,
                label: Text(_jumlahBarang > 99 ? '99+' : '$_jumlahBarang'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _tabAktif == 0 ? _beranda() : _profil(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabAktif,
        onDestinationSelected: (index) => setState(() => _tabAktif = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _beranda() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _produk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _keadaanKosong(
            ikon: Icons.cloud_off_outlined,
            judul: 'Produk belum bisa dimuat',
            pesan: 'Koneksi atau layanan produk sedang bermasalah. Coba lagi.',
            aksi: FilledButton.tonal(
              onPressed: _muatUlang,
              child: const Text('Coba lagi'),
            ),
          );
        }

        final produk = snapshot.data ?? const <Map<String, dynamic>>[];
        return RefreshIndicator(
          onRefresh: () async => _muatUlang(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sapaan(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                  child: Text(
                    'Pilihan untukmu',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  // menampilkan daftar produk dalam bentuk gridview
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: produk.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 254,
                        ),
                    itemBuilder: (context, index) =>
                        _kartuProduk(produk[index]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sapaan() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEFE8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Senang bertemu lagi,'),
                const SizedBox(height: 4),
                Text(
                  widget.pengguna,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF205D4F)
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Temukan barang favoritmu hari ini.'),
              ],
            ),
          ),
          const Icon(
            Icons.local_mall_outlined,
            size: 44,
            color: Color(0xFF287C68),
          ),
        ],
      ),
    );
  }

  Widget _kartuProduk(Map<String, dynamic> produk) {
    final nama = (produk['title'] as String?) ?? 'Produk tanpa nama';
    final harga = (produk['price'] as num?)?.toDouble() ?? 0;
    final kategori = (produk['category'] as String?) ?? 'Lainnya';
    final ratingData = produk['rating'];
    final rating = ratingData is Map
        ? (ratingData['rate'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    ratingData is Map
        ? (ratingData['count'] as num?)?.toInt() ?? 0
        : 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => _bukaProduk(produk),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: _gambarProduk(produk),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${harga.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF287C68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    kategori,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${rating.toStringAsFixed(1)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profil() {
    return ProfilePage(pengguna: widget.pengguna, onKeluar: widget.onKeluar);
  }

  Widget _keadaanKosong({
    required IconData ikon,
    required String judul,
    required String pesan,
    Widget? aksi,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 52, color: Colors.black38),
            const SizedBox(height: 14),
            Text(judul, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(pesan, textAlign: TextAlign.center),
            if (aksi != null) ...[const SizedBox(height: 14), aksi],
          ],
        ),
      ),
    );
  }
}

Widget _gambarProduk(Map<String, dynamic> produk) {
  final gambar = produk['image'];
  final alamat = gambar is String ? gambar : '';
  if (alamat.isEmpty) return const Icon(Icons.image_outlined, size: 50);
  return Image.network(
    alamat,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_outlined),
  );
}
