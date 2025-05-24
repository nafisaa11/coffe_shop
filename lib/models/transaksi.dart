// File: models/transaksi.dart
import 'package:kopiqu/models/kopi.dart';

class TransaksiItem {
  final Kopi kopi;
  final int jumlah;
  final String ukuran;
  final int hargaSatuan;
  final int total;

  TransaksiItem({
    required this.kopi,
    required this.jumlah,
    required this.ukuran,
    required this.hargaSatuan,
    required this.total,
  });
}

class Transaksi {
  final String noTransaksi;
  final String pembeli;
  final DateTime tanggal;
  final List<TransaksiItem> items;
  final int totalHarga;
  final int pajak;
  final int totalBayar;
  final int totalJumlah;

  Transaksi({
    required this.noTransaksi,
    required this.pembeli,
    required this.tanggal,
    required this.items,
    required this.totalHarga,
    required this.pajak,
    required this.totalBayar,
    required this.totalJumlah,
  });

  // Factory method untuk membuat transaksi dari data keranjang
  factory Transaksi.fromKeranjang({
    required List<Map<String, dynamic>> keranjangItems,
    required String pembeli,
  }) {
    // Generate nomor transaksi
    String noTransaksi = 'TRX${DateTime.now().millisecondsSinceEpoch}';
    
    // Konversi keranjang items ke transaksi items
    List<TransaksiItem> items = [];
    int totalHarga = 0;
    int totalJumlah = 0;
    
    for (var item in keranjangItems) {
      if (item['dipilih'] == true) {
        final kopi = item['kopi'] as Kopi;
        final jumlah = item['jumlah'] as int;
        final ukuran = item['ukuran'] ?? 'Sedang';
        
        // Hitung harga berdasarkan ukuran
        int hargaSatuan = kopi.harga;
        if (ukuran == 'Besar') {
          hargaSatuan += 5000;
        } else if (ukuran == 'Kecil') {
          hargaSatuan -= 3000;
        }
        
        int totalItem = hargaSatuan * jumlah;
        
        items.add(TransaksiItem(
          kopi: kopi,
          jumlah: jumlah,
          ukuran: ukuran,
          hargaSatuan: hargaSatuan,
          total: totalItem,
        ));
        
        totalHarga += totalItem;
        totalJumlah += jumlah;
      }
    }
    
    // Hitung pajak 10%
    int pajak = (totalHarga * 0.1).round();
    int totalBayar = totalHarga + pajak;
    
    return Transaksi(
      noTransaksi: noTransaksi,
      pembeli: pembeli,
      tanggal: DateTime.now(),
      items: items,
      totalHarga: totalHarga,
      pajak: pajak,
      totalBayar: totalBayar,
      totalJumlah: totalJumlah,
    );
  }
}