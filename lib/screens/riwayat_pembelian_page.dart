// screens/riwayat_pembelian_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/transaksi.dart'; // Pastikan path model Transaksi benar
import 'package:kopiqu/models/kopi.dart';    // Import model Kopi

class RiwayatPembelianPage extends StatelessWidget {
  const RiwayatPembelianPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil objek Transaksi dari arguments route
    // Pastikan objek Transaksi dikirim dengan benar saat navigasi ke halaman ini
    final transaksi = ModalRoute.of(context)?.settings.arguments as Transaksi?;

    if (transaksi == null) {
      // Fallback jika tidak ada data transaksi yang diterima
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Data transaksi tidak ditemukan.'),
        ),
      );
    }

    // Menggunakan NumberFormat untuk harga dari intl package
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Membuat daftar nama kopi dari items transaksi
    // Mengakses 'nama_kopi' dari dalam map item
    final daftarNamaKopi = transaksi.items
        .map((item) => item['nama_kopi'] as String? ?? 'Nama Kopi Tidak Ada')
        .toList()
        .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFFDEFE5), // Warna latar belakang yang lembut
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D2F15)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Riwayat Pembelian',
          style: TextStyle(
              color: Color(0xFF4D2F15),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Border radius lebih besar
          ),
          elevation: 5, // Sedikit lebih tinggi elevasinya
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar Card menyesuaikan konten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long,
                          color: Colors.brown.shade700, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Transaksi #${transaksi.id}', // Menggunakan transaksi.id
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildDetailRow(
                    "Nama Pembeli:", transaksi.pembeli),
                _buildDetailRow(
                    "Tanggal:", transaksi.tanggalFormatted), // Menggunakan getter
                const SizedBox(height: 12),
                Text(
                  'Item Dibeli:',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  daftarNamaKopi.isEmpty ? '-' : daftarNamaKopi,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildDetailRow(
                  "Total Produk:",
                  "${transaksi.totalProduk} item",
                ),
                _buildDetailRow(
                  "Subtotal:",
                  currencyFormat.format(transaksi.subtotal),
                ),
                _buildDetailRow(
                  "Pajak (10%):",
                  currencyFormat.format(transaksi.pajak),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade800),
                    ),
                    Text(
                      currencyFormat.format(transaksi.totalPembayaran), // Menggunakan transaksi.totalPembayaran
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Lebih besar untuk total
                          color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
