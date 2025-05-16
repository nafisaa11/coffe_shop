import 'package:kopiqu/models/kopi.dart';

class Transaksi {
  final String pembeli;
  final String noTransaksi;
  final DateTime tanggal;
  final List<ItemTransaksi> items;

  Transaksi({
    required this.pembeli,
    required this.noTransaksi,
    required this.tanggal,
    required this.items,
  });

  int get totalJumlah => items.fold(0, (sum, item) => sum + item.jumlah);
  int get totalHarga => items.fold(0, (sum, item) => sum + item.total);
  double get pajak => totalHarga * 0.10;
  double get totalBayar => totalHarga + pajak;
}

class ItemTransaksi {
  final Kopi kopi;
  final int jumlah;

  ItemTransaksi({required this.kopi, required this.jumlah});

  int get total => kopi.harga * jumlah;
}
