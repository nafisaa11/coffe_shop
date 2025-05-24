import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:kopiqu/models/transaksi.dart';
import 'package:kopiqu/screens/struk.dart';
import 'package:kopiqu/widgets/Transaksi/ringkasanPesanan_widget.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:intl/intl.dart';

class PeriksaPesananScreen extends StatefulWidget {
  const PeriksaPesananScreen({super.key});

  @override
  State<PeriksaPesananScreen> createState() => _PeriksaPesananScreenState();
}

class _PeriksaPesananScreenState extends State<PeriksaPesananScreen> {
  final TextEditingController _namaPembeliController = TextEditingController();

  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  void _buatPesanan(KeranjangController keranjangCtrl) {
    if (_namaPembeliController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama pembeli'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Buat transaksi dari data keranjang
    final transaksi = Transaksi.fromKeranjang(
      keranjangItems: keranjangCtrl.keranjang,
      pembeli: _namaPembeliController.text.trim(),
    );

    // Navigasi ke halaman struk
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StrukPage(transaksi: transaksi)),
    ).then((_) {
      // Setelah kembali dari struk, bersihkan keranjang
      keranjangCtrl.bersihkanKeranjang();
      // Kembali ke halaman utama
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    _namaPembeliController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E9DE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Periksa Pesanan',
          style: TextStyle(
            color: Colors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          // Filter hanya item yang dipilih
          final itemDipilih =
              keranjangCtrl.keranjang
                  .where((item) => item['dipilih'] == true)
                  .toList();

          // Hitung total item
          int totalItem = 0;
          for (var item in itemDipilih) {
            totalItem += item['jumlah'] as int;
          }

          // Hitung subtotal
          int subtotal = 0;
          for (var item in itemDipilih) {
            final kopi = item['kopi'] as Kopi;
            final jumlah = item['jumlah'] as int;
            final ukuran = item['ukuran'] ?? 'Sedang';

            int hargaItem = kopi.harga;
            // Tambah harga berdasarkan ukuran
            if (ukuran == 'Besar') {
              hargaItem += 5000;
            } else if (ukuran == 'Kecil') {
              hargaItem -= 3000;
            }

            subtotal += hargaItem * jumlah;
          }

          // Hitung pajak (10%)
          int pajak = (subtotal * 0.1).round();

          // Total pembayaran
          int totalPembayaran = subtotal + pajak;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: RingkasanPesanan(
                    namaPembeliController: _namaPembeliController,
                    itemDipilih: itemDipilih,
                    totalItem: totalItem,
                    subtotal: subtotal,
                    pajak: pajak,
                    totalPembayaran: totalPembayaran,
                  ),
                ),
              ),

              // Button Buat Pesanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ElevatedButton(
                  onPressed: () => _buatPesanan(keranjangCtrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buat Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
