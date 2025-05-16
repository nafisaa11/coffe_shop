import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/transaksi.dart';

class StrukPage extends StatelessWidget {
  final Transaksi transaksi;

  const StrukPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0', 'id_ID');
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFFA05A2C),
      body: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFF4D2F15)),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // STRUK PUTIH
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/kopiqu.png", height: 40),
                            const SizedBox(height: 8),
                            const Text(
                              "Jl. Kertajaya Indah, No.4",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 134, 123, 118),
                              ),
                            ),
                            const Text(
                              "087777777777",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 134, 123, 118),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Transaksi
                      Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "Pembeli",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(": ${transaksi.pembeli}"),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 4.0, 8.0, 4.0),
                                child: Text(
                                  "No. Transaksi",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(": ${transaksi.noTransaksi}"),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "Tanggal",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Text(
                                  ": ${dateFormat.format(transaksi.tanggal)} WIB",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 24),

                      // Tabel Produk
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(82, 211, 133, 74),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  "PRODUK",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  "JML",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  "HARGA",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  "TOTAL",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              SizedBox(height: 8),
                              SizedBox(height: 8),
                              SizedBox(height: 8),
                              SizedBox(height: 8),
                            ],
                          ),
                          ...transaksi.items.map(
                            (item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Text(item.kopi.nama.toUpperCase()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Text("x${item.jumlah}"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    currencyFormat.format(item.kopi.harga),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    currencyFormat.format(item.total),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(thickness: 1, height: 24),

                      // Ringkasan
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text("TOTAL HARGA"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text("${transaksi.totalJumlah}"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  currencyFormat.format(transaksi.totalHarga),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text("PAJAK"),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text("10%"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  currencyFormat.format(transaksi.pajak),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  "TOTAL BAYAR",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  currencyFormat.format(transaksi.totalBayar),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),
                      const Center(
                        child: Text(
                          "Terima kasih telah berkunjung ke KopiQu!\nSelamat menikmati kopi Anda",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 134, 123, 118),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "BAYAR DI KASIR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 20),
                //                 // TEKS DI LUAR STRUK
                //                 const Text(
                //                   "BAYAR DI KASIR",
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 16,
                //                     color: Colors.white,
                //                   ),
                //                 ),
                //                 const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
