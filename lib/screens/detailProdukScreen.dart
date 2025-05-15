import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/detail_widget.dart';

class DetailProdukScreen extends StatefulWidget {
  final int id;

  DetailProdukScreen({super.key, required this.id});
  // const DetailProdukScreen({super.key});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  late Kopi kopi;
  // String ukuranDipilih = 'Kecil';

  @override
  void initState() {
    super.initState();
    try {
      kopi = kopiList.firstWhere((k) => k.id == widget.id);
    } catch (e) {
      // fallback jika id tidak ditemukan
      kopi = kopiList.first;
    }
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
              Image.asset(
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
            child: DetailWidget(
              kopi: kopi,
              onTambah: (ukuran) => tambahKeKeranjang(context, ukuran),
            ),
          ),
        ],
      ),
    );
  }
}
