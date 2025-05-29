// models/keranjang_item.dart
import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar

class KeranjangItem {
  final Kopi kopi; 
  String ukuran;    
  int jumlah;      
  bool dipilih;     

  KeranjangItem({
    required this.kopi,
    required this.ukuran,
    this.jumlah = 1,
    this.dipilih = true,
  });
}