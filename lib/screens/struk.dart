// screens/struk_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/transaksi.dart'; // Pastikan path model Transaksi benar

class StrukPage extends StatelessWidget {
  final Transaksi transaksi;

  const StrukPage({super.key, required this.transaksi});

  // Helper widget untuk membuat baris info (label: nilai)
  Widget _buildInfoRow(String label, String value, {FontWeight labelWeight = FontWeight.w600, TextAlign valueAlign = TextAlign.right}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, // Lebar untuk label
            child: Text(label, style: TextStyle(fontWeight: labelWeight, fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3, // Lebar untuk nilai
            child: Text(value, style: const TextStyle(fontSize: 12.5), textAlign: valueAlign),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk header tabel item
  Widget _buildItemHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.black54);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text("PRODUK", style: headerStyle)), // Nama produk lebih lebar
          Expanded(flex: 1, child: Text("JML", style: headerStyle, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text("HARGA", style: headerStyle, textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text("SUBTOTAL", style: headerStyle, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  // Helper widget untuk setiap baris item produk
  Widget _buildItemRow(Map<String, dynamic> item, NumberFormat currencyFormat) {
    // Mengambil data dari map item (sesuai struktur di Transaksi.fromKeranjang)
    final String namaKopi = item['nama_kopi'] as String? ?? 'Produk Tidak Dikenal';
    final int jumlah = item['jumlah'] as int? ?? 0;
    final int hargaSatuan = item['harga_satuan_saat_transaksi'] as int? ?? 0;
    final int totalHargaItem = item['total_harga_item'] as int? ?? 0;
    final String ukuran = item['ukuran'] as String? ?? '';

    final itemStyle = TextStyle(fontSize: 11.5, color: Colors.grey[800]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaKopi, style: itemStyle.copyWith(fontWeight: FontWeight.w500, color: Colors.black)),
                if (ukuran.isNotEmpty) 
                  Text("Ukuran: $ukuran", style: itemStyle.copyWith(fontSize: 10.5, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text("x$jumlah", style: itemStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Text(currencyFormat.format(hargaSatuan), style: itemStyle, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 3,
            child: Text(currencyFormat.format(totalHargaItem), style: itemStyle, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID', // Menggunakan id_ID untuk format Rupiah yang benar
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    // Menggunakan getter tanggalFormatted dari model Transaksi untuk konsistensi
    // final dateFormat = DateFormat('dd-MM-yyyy HH:mm'); // Tidak perlu jika menggunakan transaksi.tanggalFormatted

    return Scaffold(
      backgroundColor: const Color(0xFF8D6E63), // Warna latar coklat tua untuk keseluruhan halaman
      appBar: AppBar(
        title: const Text('Struk Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF4D2F15), // Warna coklat sangat tua untuk AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Tombol kembali putih
        leading: IconButton(
          icon: const Icon(Icons.close), // Icon close lebih cocok untuk menutup struk
          onPressed: () {
            // Aksi saat tombol close ditekan (kembali ke halaman root)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF3E2723), fontFamily: 'sans-serif'), // Font default lebih modern
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Image.asset("assets/kopiqu.png", height: 50), // Pastikan path aset benar
                                const SizedBox(height: 10),
                                const Text(
                                  "KOPIQU",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Jl. Kertajaya Indah No.4, Surabaya",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                                ),
                                Text(
                                  "Telp: 0877-7777-7777",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          _buildInfoRow("Nama Pembeli", transaksi.pembeli),
                          _buildInfoRow("No. Struk", transaksi.id), // Menggunakan transaksi.id
                          _buildInfoRow("Tanggal", transaksi.tanggalFormatted), // Menggunakan getter dari model

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(thickness: 0.5, color: Colors.black26),
                          ),
                          
                          _buildItemHeader(), // Header untuk daftar item
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26),
                          const SizedBox(height: 4),

                          // Loop untuk menampilkan item-item transaksi
                          if (transaksi.items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text("Tidak ada item dalam transaksi ini.", style: TextStyle(fontStyle: FontStyle.italic))),
                            )
                          else
                            ...transaksi.items.map( // Menggunakan spread operator untuk memasukkan list TableRow
                              (item) => _buildItemRow(item, currencyFormat),
                            ).toList(),
                          
                          const Divider(thickness: 0.5, height: 1, color: Colors.black26),
                          const SizedBox(height: 20),

                          // Ringkasan Total Pembayaran
                          _buildInfoRow("Subtotal (${transaksi.totalProduk} Produk)", currencyFormat.format(transaksi.subtotal), valueAlign: TextAlign.right),
                          _buildInfoRow("Pajak (10%)", currencyFormat.format(transaksi.pajak), valueAlign: TextAlign.right),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(thickness: 1, color: Colors.black38),
                          ),
                          _buildInfoRow(
                            "TOTAL PEMBAYARAN", 
                            currencyFormat.format(transaksi.totalPembayaran), 
                            labelWeight: FontWeight.bold, 
                            valueAlign: TextAlign.right
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: Text(
                              "Terima kasih telah memesan di KopiQu!\nSilakan lakukan pembayaran di kasir.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Center(
                            child: Text(
                              "--- BAYAR DI KASIR ---",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF4D2F15),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: () {
                           Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Selesai & Kembali ke Menu"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D2F15),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
