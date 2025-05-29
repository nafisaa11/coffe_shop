import 'package:kopiqu/models/transaksi.dart'; // Model Transaksi Anda yang sudah ada

class RiwayatTransaksi {
  final String id; 
  final String userId;
  final String
  nomorStruk; 
  final String pembeli; // Nama pembeli
  final List<Map<String, dynamic>>
  items; 
  final int totalProduk; 
  final int subtotal;
  final int pajak; 
  final int totalPembayaran; // Total yang harus dibayar
  final DateTime tanggalTransaksi; // Waktu transaksi dibuat oleh pengguna
  final DateTime
  createdAt; 

  RiwayatTransaksi({
    required this.id,
    required this.userId,
    required this.nomorStruk,
    required this.pembeli,
    required this.items,
    required this.totalProduk,
    required this.subtotal,
    required this.pajak,
    required this.totalPembayaran,
    required this.tanggalTransaksi,
    required this.createdAt,
  });

  factory RiwayatTransaksi.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null ||
        map['user_id'] == null ||
        map['nomor_struk'] == null ||
        map['items'] == null ||
        map['tanggal_transaksi'] == null ||
        map['created_at'] == null) {
      throw ArgumentError(
        "Data dari Supabase tidak lengkap untuk membuat RiwayatTransaksi.",
      );
    }

    return RiwayatTransaksi(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nomorStruk: map['nomor_struk'] as String,
      pembeli:
          map['nama_pembeli'] as String? ??
          'Pembeli', 
      items: List<Map<String, dynamic>>.from(
        map['items'] as List? ?? [],
      ),
      totalProduk: map['total_produk'] as int? ?? 0,
      subtotal: map['subtotal'] as int? ?? 0,
      pajak: map['pajak'] as int? ?? 0,
      totalPembayaran: map['total_pembayaran'] as int? ?? 0,
      tanggalTransaksi: DateTime.parse(map['tanggal_transaksi'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  Transaksi toTransaksiModel() {
    return Transaksi(
      id: nomorStruk, // Menggunakan nomorStruk sebagai ID untuk model Transaksi
      pembeli: pembeli,
      items: items, // items sudah dalam format List<Map<String, dynamic>>
      totalProduk: totalProduk,
      subtotal: subtotal,
      pajak: pajak,
      totalPembayaran: totalPembayaran,
      tanggalTransaksi: tanggalTransaksi,
    );
  }
}
