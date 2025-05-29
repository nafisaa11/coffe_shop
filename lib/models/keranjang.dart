// models/keranjang_item.dart
import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar

class KeranjangItem {
  final Kopi kopi; // Objek Kopi
  String ukuran;    // Ukuran yang dipilih, bisa diubah
  int jumlah;       // Jumlah item, bisa diubah
  bool dipilih;     // Status apakah item dipilih untuk checkout, bisa diubah

  KeranjangItem({
    required this.kopi,
    required this.ukuran,
    required this.jumlah,
    required this.dipilih,
  });
}