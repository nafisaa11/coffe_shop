import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart'; // Untuk pemformatan tanggal

class Transaksi {
  final String id;
  final String pembeli;
  final List<Map<String, dynamic>>
  items; // Setiap map merepresentasikan item di keranjang
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

  factory Transaksi.fromKeranjang({
    required List<Map<String, dynamic>> keranjangItemsDipilih,
    required String pembeli,
  }) {
    int calculatedTotalProduk = 0;
    int calculatedSubtotal = 0;
    List<Map<String, dynamic>> itemsUntukTransaksi = [];

    for (var itemMap in keranjangItemsDipilih) {
      final Kopi kopi = itemMap['kopi'] as Kopi;
      final int jumlah = itemMap['jumlah'] as int;
      final String ukuran = itemMap['ukuran'] as String? ?? 'Sedang';

      calculatedTotalProduk += jumlah;

      int hargaItemSatuan = kopi.harga;
      if (ukuran == 'Besar') {
        hargaItemSatuan += 5000;
      } else if (ukuran == 'Kecil') {
        hargaItemSatuan -= 3000;
        if (hargaItemSatuan < 0) hargaItemSatuan = 0;
      }
      calculatedSubtotal += hargaItemSatuan * jumlah;

      itemsUntukTransaksi.add({
        'kopi_id': kopi.id, 
        'nama_kopi': kopi.nama_kopi,
        'gambar': kopi.gambar,
        'jumlah': jumlah,
        'ukuran': ukuran,
        'harga_satuan_saat_transaksi': hargaItemSatuan,
        'total_harga_item': hargaItemSatuan * jumlah,
      });
    }

    final int calculatedPajak = (calculatedSubtotal * 0.1).round();
    final int calculatedTotalPembayaran = calculatedSubtotal + calculatedPajak;
    final String transaksiId = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

    return Transaksi(
      id: transaksiId,
      pembeli: pembeli,
      items: itemsUntukTransaksi,
      totalProduk: calculatedTotalProduk,
      subtotal: calculatedSubtotal,
      pajak: calculatedPajak,
      totalPembayaran: calculatedTotalPembayaran,
      tanggalTransaksi: DateTime.now(),
    );
  }

  String get tanggalFormatted {
    return DateFormat(
      'dd MMMM finalList, HH:mm',
      'id_ID',
    ).format(tanggalTransaksi);
  }
}
