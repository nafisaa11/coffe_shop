import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:intl/intl.dart';

class KeranjangScreen extends StatelessWidget {
  const KeranjangScreen({super.key});

  String formatRupiah(int harga) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7E9DE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Keranjang KopiQu', style: TextStyle(color: Colors.brown)),
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

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: dipilih,
                            onChanged: (_) => keranjangCtrl.togglePilih(kopi),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(kopi.gambar),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kopi.nama,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('Kecil'),
                                Text(formatRupiah(kopi.harga)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () =>
                                keranjangCtrl.ubahJumlah(kopi, -1),
                          ),
                          Text('$jumlah'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () =>
                                keranjangCtrl.ubahJumlah(kopi, 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => keranjangCtrl.hapus(kopi),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
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
                      onChanged: (val) =>
                          keranjangCtrl.pilihSemua(val ?? false),
                    ),
                    const Text('Semua'),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: keranjangCtrl.totalHarga > 0
                          ? () {
                              // Navigasi ke checkout / transaksi
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Pesan ${formatRupiah(keranjangCtrl.totalHarga)}'),
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
