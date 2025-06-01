import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/transaksi.dart'; // Pastikan path model Transaksi benar

class StrukPage extends StatelessWidget {
  final Transaksi transaksi;

  const StrukPage({super.key, required this.transaksi});

  // Helper widget untuk membuat baris info (label: nilai)
  Widget _buildInfoRow(
    String label,
    String value, {
    FontWeight labelWeight = FontWeight.w600,
    TextAlign valueAlign = TextAlign.right,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: labelWeight,
                fontSize: 11.5,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: valueAlign,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk header tabel item dengan design yang lebih sederhana
  Widget _buildItemHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF6D4C41),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 4,
            child: Text(
              "PRODUK",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "JML",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "HARGA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk setiap baris item produk yang lebih sederhana
  Widget _buildItemRow(Map<String, dynamic> item, NumberFormat currencyFormat) {
    final String namaKopi =
        item['nama_kopi'] as String? ?? 'Produk Tidak Dikenal';
    final int jumlah = item['jumlah'] as int? ?? 0;
    final int hargaSatuan = item['harga_satuan_saat_transaksi'] as int? ?? 0;
    final int totalHargaItem = item['total_harga_item'] as int? ?? 0;
    final String ukuran = item['ukuran'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaKopi,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4D2F15),
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ukuran.isNotEmpty)
                  Text(
                    ukuran,
                    style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "x$jumlah",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4D2F15),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              currencyFormat.format(hargaSatuan),
              style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              currencyFormat.format(totalHargaItem),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4D2F15),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG StrukPage] Build dimulai. Transaksi ID: ${transaksi.id}');
    print('[DEBUG StrukPage] Jumlah item di struk: ${transaksi.items.length}');

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor:
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8D6E63), Color(0xFFA1887F)],
          ).colors.first,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD07C3D),
              Color(0xFFD07C3D), // Atau tambahkan warna lain jika diinginkan
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar yang lebih sederhana
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(color: Color(0xFFD07C3D)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Struk Pembayaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Main Receipt Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header Section dengan Logo yang lebih compact
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/kopiqu.png",
                                      height: 40,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Jl. Kertajaya Indah No.4, Surabaya",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      "Telp: 0877-7777-7777",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Transaction Info Section yang lebih compact
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildInfoRow(
                                            "Nama Pembeli",
                                            transaksi.pembeli,
                                          ),
                                          _buildInfoRow(
                                            "No. Struk",
                                            transaksi.id,
                                          ),
                                          _buildInfoRow(
                                            "Tanggal",
                                            transaksi.tanggalFormatted,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Items Section
                                    _buildItemHeader(),

                                    if (transaksi.items.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          "Tidak ada item dalam transaksi ini.",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    else
                                      ...transaksi.items
                                          .map(
                                            (item) => _buildItemRow(
                                              item,
                                              currencyFormat,
                                            ),
                                          )
                                          .toList(),

                                    const SizedBox(height: 12),

                                    // Total Section yang lebih compact
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildInfoRow(
                                            "Subtotal (${transaksi.totalProduk} Produk)",
                                            currencyFormat.format(
                                              transaksi.subtotal,
                                            ),
                                            valueAlign: TextAlign.right,
                                          ),
                                          _buildInfoRow(
                                            "Pajak (10%)",
                                            currencyFormat.format(
                                              transaksi.pajak,
                                            ),
                                            valueAlign: TextAlign.right,
                                          ),
                                          const Divider(
                                            height: 16,
                                            thickness: 1,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "TOTAL PEMBAYARAN",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Color(0xFF4D2F15),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  currencyFormat.format(
                                                    transaksi.totalPembayaran,
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Color(0xFF4D2F15),
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Thank you message
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            color: Colors.green[600],
                                            size: 24,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Terima kasih telah memesan di KopiQu!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Silakan lakukan pembayaran di kasir.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4D2F15), Color(0xFF6D4C41)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF4D2F15).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 22,
                            ),
                            label: const Text(
                              "Selesai & Kembali ke Menu",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
