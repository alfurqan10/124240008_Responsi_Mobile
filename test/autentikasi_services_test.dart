import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/services/autentikasi_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'keranjang tersimpan per pengguna dan menghitung jumlah barang',
    () async {
      SharedPreferences.setMockInitialValues({});
      const produk = {
        'id': 1,
        'title': 'Tas',
        'price': 12.5,
        'image': 'https://example.com/tas.jpg',
      };

      await AuthService.login('pengguna@example.com', 'password');
      await AuthService.tambahProduk('pengguna@example.com', produk, 2);
      await AuthService.tambahProduk('pengguna@example.com', produk, 1);
      await AuthService.login('lain@example.com', 'password');

      expect(AuthService.jumlahBarang('pengguna@example.com'), 3);
      expect(AuthService.isiKeranjang('pengguna@example.com'), hasLength(1));
      expect(AuthService.jumlahBarang('lain@example.com'), 0);

      await AuthService.hapusProduk('pengguna@example.com', '1');
      expect(AuthService.jumlahBarang('pengguna@example.com'), 0);
    },
  );
}
