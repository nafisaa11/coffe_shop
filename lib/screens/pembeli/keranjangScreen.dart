import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/keranjang/Keranjang_Controller.dart';
import 'package:kopiqu/models/keranjang.dart';
import 'package:kopiqu/screens/pembeli/transaksiScreen.dart';
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
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          final keranjang = keranjangCtrl.keranjang;
          final keranjangHabis = keranjangCtrl.keranjangHabis;
          final hasItems = keranjang.isNotEmpty || keranjangHabis.isNotEmpty;

          if (!hasItems) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.brown[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang Anda Kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.brown[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai belanja untuk menambah kopi ke keranjang',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header info
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.brown[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Harga akan berubah sesuai ukuran yang dipilih',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.brown[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section untuk produk tersedia
                      if (keranjang.isNotEmpty) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: keranjang.length,
                          itemBuilder: (context, index) {
                            final KeranjangItem item = keranjang[index];
                            return KeranjangCardWidget(
                              item: item,
                            );
                          },
                        ),
                      ],

                      // Section untuk produk terjual habis
                      if (keranjangHabis.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        
                        // Sub judul "Terjual Habis"
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[400],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Terjual Habis',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[400],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // List produk terjual habis
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: keranjangHabis.length,
                          itemBuilder: (context, index) {
                            final KeranjangItem item = keranjangHabis[index];
                            return Opacity(
                              opacity: 0.6, // Buat tampilan lebih redup
                              child: Stack(
                                children: [
                                  KeranjangCardWidget(
                                    item: item,
                                  ),
                                  // Overlay untuk menunjukkan item tidak bisa dipilih
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red[600],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'HABIS',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      
                      // Spacing untuk bottom container
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Total Harga yang dipilih - hanya tampil jika ada item tersedia
              if (keranjang.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Checkbox pilih semua
                        Row(
                          children: [
                            Checkbox(
                              value: keranjangCtrl.semuaDipilih,
                              onChanged: (val) => keranjangCtrl.pilihSemua(val ?? false),
                              activeColor: Colors.brown,
                            ),
                            Text(
                              'Pilih Semua (${keranjang.where((item) => item.dipilih).length}/${keranjang.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Total dan button pesan
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Pembayaran',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatRupiah(keranjangCtrl.totalHarga),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Button pesan
                            ElevatedButton(
                              onPressed: keranjangCtrl.totalHarga > 0
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PeriksaPesananScreen(),
                                        ),
                                      );
                                    }
                                  : null,
                                                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                'Pesan Sekarang',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}