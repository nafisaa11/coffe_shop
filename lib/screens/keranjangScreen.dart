import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:kopiqu/widgets/keranjangCard_widget.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:intl/intl.dart';

class KeranjangScreen extends StatelessWidget {
  KeranjangScreen({super.key});

  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7E9DE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Keranjang KopiQu',
          style: TextStyle(color: Colors.brown),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          final keranjang = keranjangCtrl.keranjang;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: keranjang.length,
                  itemBuilder: (context, index) {
                    final item = keranjang[index];
                    final kopi = item['kopi'] as Kopi;
                    final jumlah = item['jumlah'];
                    final dipilih = item['dipilih'];
                    final ukuran = item['ukuran'] ?? 'Sedang';

                    return KeranjangCardWidget(
                      kopi: kopi,
                      jumlah: jumlah,
                      dipilih: dipilih,
                      ukuran: ukuran,
                      onUkuranChanged: (newUkuran) {
                        if (newUkuran != null) {
                          keranjangCtrl.ubahUkuran(
                            kopi,
                            ukuran,
                            newUkuran,
                          ); // Pass ukuran lama juga
                        }
                      },
                    );
                  },
                ),
              ),

              // Total Harga yang dipilih
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: keranjangCtrl.semuaDipilih,
                      onChanged:
                          (val) => keranjangCtrl.pilihSemua(val ?? false),
                    ),
                    const Text('Semua'),
                    const Spacer(),

                    // Nutton melanjutkan ke checkout
                    ElevatedButton(
                      onPressed:
                          keranjangCtrl.totalHarga > 0
                              ? () {
                                // Navigasi ke checkout / transaksi
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Pesan ${formatRupiah(keranjangCtrl.totalHarga)}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
