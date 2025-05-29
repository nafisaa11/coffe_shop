// models/transaksi.dart
import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart'; // Untuk pemformatan tanggal

class Transaksi {
  final String id;
  final String pembeli;
  final List<Map<String, dynamic>> items; // Setiap map merepresentasikan item di keranjang
                                         // dengan key 'kopi', 'jumlah', 'ukuran'
  final int totalProduk;
  final int subtotal;
  final int pajak;
  final int totalPembayaran;
  final DateTime tanggalTransaksi;

  Transaksi({
    required this.id,
    required this.pembeli,
    required this.items,
    required this.totalProduk,
    required this.subtotal,
    required this.pajak,
    required this.totalPembayaran,
    required this.tanggalTransaksi,
  });

  // Factory constructor untuk membuat objek Transaksi dari item keranjang yang dipilih dan nama pembeli
  // Logika perhitungan (subtotal, pajak, total) dilakukan di sini berdasarkan item yang diterima.
  factory Transaksi.fromKeranjang({
    required List<Map<String, dynamic>> keranjangItemsDipilih, // Ini adalah item yang sudah dipilih dan difilter
    required String pembeli,
  }) {
    int calculatedTotalProduk = 0;
    int calculatedSubtotal = 0;

    // Membuat salinan item untuk disimpan dalam transaksi agar tidak terpengaruh perubahan di keranjang
    List<Map<String, dynamic>> itemsUntukTransaksi = [];

    for (var itemMap in keranjangItemsDipilih) {
      final Kopi kopi = itemMap['kopi'] as Kopi;
      final int jumlah = itemMap['jumlah'] as int;
      final String ukuran = itemMap['ukuran'] as String? ?? 'Sedang';

      calculatedTotalProduk += jumlah;

      int hargaItemSatuan = kopi.harga;
      // Penyesuaian harga berdasarkan ukuran
      if (ukuran == 'Besar') {
        hargaItemSatuan += 5000;
      } else if (ukuran == 'Kecil') {
        hargaItemSatuan -= 3000; // Pastikan harga tidak menjadi negatif
        if (hargaItemSatuan < 0) hargaItemSatuan = 0;
      }
      calculatedSubtotal += hargaItemSatuan * jumlah;

      // Menambahkan item yang sudah diproses (termasuk harga satuan yang disesuaikan) ke daftar transaksi
      itemsUntukTransaksi.add({
        'kopi': kopi, // Sebaiknya simpan ID atau representasi Kopi yang lebih stabil jika Kopi bisa berubah
        'nama_kopi': kopi.nama_kopi, // Simpan detail yang relevan saat transaksi
        'gambar': kopi.gambar,
        'jumlah': jumlah,
        'ukuran': ukuran,
        'harga_satuan_saat_transaksi': hargaItemSatuan, // Simpan harga saat itu
        'total_harga_item': hargaItemSatuan * jumlah,
      });
    }

    final int calculatedPajak = (calculatedSubtotal * 0.1).round();
    final int calculatedTotalPembayaran = calculatedSubtotal + calculatedPajak;
    
    // ID Transaksi sederhana berbasis waktu
    final String transaksiId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

    return Transaksi(
      id: transaksiId,
      pembeli: pembeli,
      items: itemsUntukTransaksi, // Gunakan daftar item yang sudah diproses
      totalProduk: calculatedTotalProduk,
      subtotal: calculatedSubtotal,
      pajak: calculatedPajak,
      totalPembayaran: calculatedTotalPembayaran,
      tanggalTransaksi: DateTime.now(),
    );
  }

  // Helper untuk memformat tanggal jika diperlukan untuk tampilan
  String get tanggalFormatted {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(tanggalTransaksi);
  }
}
