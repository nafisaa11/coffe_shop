import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/models/keranjang.dart';
import 'package:kopiqu/screens/transaksiScreen.dart';
import 'package:kopiqu/widgets/keranjangCard_widget.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:intl/intl.dart';

class KeranjangScreen extends StatefulWidget {
  KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  @override
  void initState() {
    super.initState();
    // Hanya fetch jika keranjang kosong atau jika diperlukan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keranjangCtrl = Provider.of<KeranjangController>(context, listen: false);
      if (keranjangCtrl.keranjang.isEmpty) {
        keranjangCtrl.fetchKeranjangItems();
      }
    });
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
                    final KeranjangItem item = keranjang[index];

                    return KeranjangCardWidget(
                      item: item, // Teruskan seluruh objek KeranjangItem
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PeriksaPesananScreen(),
                                  ),
                                );
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
