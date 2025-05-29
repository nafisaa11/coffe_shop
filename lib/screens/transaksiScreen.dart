// screens/periksa_pesanan_screen.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/models/transaksi.dart';
import 'package:kopiqu/screens/struk.dart';
import 'package:kopiqu/widgets/Transaksi/ringkasanPesanan_widget.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/models/keranjang.dart';
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
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // PERBAIKAN: Gunakan itemDipilih yang sudah benar dari controller
    final List<KeranjangItem> itemKeranjangDipilih = keranjangCtrl.itemDipilih;
    
    // Pastikan ada item yang dipilih sebelum membuat transaksi
    if (itemKeranjangDipilih.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada item yang dipilih untuk dipesan.'),
          backgroundColor: Colors.orangeAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Konversi KeranjangItem ke format yang dibutuhkan Transaksi.fromKeranjang
    final List<Map<String, dynamic>> itemYangAkanDipesan = itemKeranjangDipilih.map((keranjangItem) => {
      'kopi': keranjangItem.kopi,
      'jumlah': keranjangItem.jumlah,
      'ukuran': keranjangItem.ukuran,
      'dipilih': keranjangItem.dipilih,
    }).toList();

    // Buat transaksi dari item yang sudah dipilih
    final transaksi = Transaksi.fromKeranjang(
      keranjangItemsDipilih: itemYangAkanDipesan,
      pembeli: _namaPembeliController.text.trim(),
    );

    // Navigasi ke halaman struk
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StrukPage(transaksi: transaksi)),
    ).then((_) {
      // Setelah kembali dari struk, bersihkan HANYA item yang sudah dipesan (yang dipilih)
      keranjangCtrl.bersihkanItemDipilih();
      
      // Kembali ke halaman utama (root)
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          // PERBAIKAN: Ambil item yang dipilih langsung dari controller
          final List<KeranjangItem> itemKeranjangDipilih = keranjangCtrl.itemDipilih;
          
          // Konversi ke format Map untuk kompatibilitas dengan RingkasanPesanan widget
          final List<Map<String, dynamic>> itemUntukDitampilkan = itemKeranjangDipilih.map((keranjangItem) => {
            'kopi': keranjangItem.kopi,
            'jumlah': keranjangItem.jumlah,
            'ukuran': keranjangItem.ukuran,
            'dipilih': keranjangItem.dipilih,
          }).toList();

          int totalItem = 0;
          for (var keranjangItem in itemKeranjangDipilih) {
            totalItem += keranjangItem.jumlah;
          }

          int subtotal = 0;
          for (var keranjangItem in itemKeranjangDipilih) {
            final kopi = keranjangItem.kopi;
            final jumlah = keranjangItem.jumlah;
            final ukuran = keranjangItem.ukuran;

            int hargaItem = kopi.harga;
            if (ukuran == 'Besar') {
              hargaItem += 5000;
            } else if (ukuran == 'Kecil') {
              hargaItem -= 3000;
              if (hargaItem < 0) hargaItem = 0;
            }
            subtotal += hargaItem * jumlah;
          }

          int pajak = (subtotal * 0.1).round();
          int totalPembayaran = subtotal + pajak;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: RingkasanPesanan(
                    namaPembeliController: _namaPembeliController,
                    itemDipilih: itemUntukDitampilkan,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: itemUntukDitampilkan.isEmpty
                      ? null 
                      : () => _buatPesanan(keranjangCtrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Buat Pesanan Sekarang'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}