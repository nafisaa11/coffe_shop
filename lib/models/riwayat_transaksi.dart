// models/riwayat_transaksi.dart
import 'package:kopiqu/models/transaksi.dart'; // Model Transaksi Anda yang sudah ada

// Model ini merepresentasikan data yang disimpan dan diambil dari tabel 'riwayat_transaksi' di Supabase.
class RiwayatTransaksi {
  final String id; // ID unik dari tabel Supabase (UUID, primary key)
  final String userId; // ID pengguna yang melakukan transaksi
  final String
  nomorStruk; // Nomor struk yang digenerate aplikasi (dari Transaksi.id)
  final String pembeli; // Nama pembeli
  final List<Map<String, dynamic>>
  items; // Detail item yang dibeli, disimpan sebagai JSONB
  final int totalProduk; // Jumlah total semua item
  final int subtotal; // Total harga sebelum pajak
  final int pajak; // Jumlah pajak
  final int totalPembayaran; // Total yang harus dibayar
  final DateTime tanggalTransaksi; // Waktu transaksi dibuat oleh pengguna
  final DateTime
  createdAt; // Timestamp kapan baris data ini dimasukkan ke database (dari Supabase)

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

  // Factory constructor untuk membuat instance RiwayatTransaksi dari Map (data JSON dari Supabase)
  factory RiwayatTransaksi.fromMap(Map<String, dynamic> map) {
    // Validasi dasar untuk memastikan field penting ada dan bertipe benar
    // Anda bisa menambahkan validasi yang lebih ketat jika perlu
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
          'Pembeli', // Memberi nilai default jika null
      // Pastikan 'items' di Supabase adalah JSON array of objects
      items: List<Map<String, dynamic>>.from(
        map['items'] as List? ?? [],
      ), // Memberi nilai default jika null
      totalProduk: map['total_produk'] as int? ?? 0,
      subtotal: map['subtotal'] as int? ?? 0,
      pajak: map['pajak'] as int? ?? 0,
      totalPembayaran: map['total_pembayaran'] as int? ?? 0,
      tanggalTransaksi: DateTime.parse(map['tanggal_transaksi'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Method untuk mengkonversi objek RiwayatTransaksi ini menjadi objek Transaksi
  // Ini berguna agar halaman detail riwayat Anda (RiwayatPembelianPage)
  // yang mengharapkan objek Transaksi tidak perlu banyak diubah.
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
