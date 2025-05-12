import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/detail_widget.dart';
import 'package:intl/intl.dart';

class DetailProdukScreen extends StatefulWidget {
  final int id;

  DetailProdukScreen({super.key, required this.id});
  // const DetailProdukScreen({super.key});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  late Kopi kopi;
  String ukuranDipilih = 'Kecil';
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    try {
      kopi = kopiList.firstWhere((k) => k.id == widget.id);
    } catch (e) {
      // fallback jika id tidak ditemukan
      kopi = kopiList.first;
    }
    kopi = kopiList[widget.id]; // Pastikan id valid
  }

  void tambahKeKeranjang(BuildContext context, String ukuran) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ditambahkan: ${kopi.nama} ukuran $ukuran ke keranjang'),
      ),
    );
    // Tambahkan logika simpan ke keranjang di sini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.network(
                kopi.gambar,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Text(
                  kopi.nama,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: DetailWidget(
                  kopi: kopi,
                  onTambah: (ukuran) => tambahKeKeranjang(context, ukuran),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFFF7E9DE)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatRupiah.format(kopi.harga),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => tambahKeKeranjang(context, ukuranDipilih),
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
