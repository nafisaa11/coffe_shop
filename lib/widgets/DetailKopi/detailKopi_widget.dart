import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart'; // Pastikan path ini benar
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/DetailKopi/ukuranGelas_widget.dart'; // Pastikan path ini benar
import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Tidak lagi diperlukan untuk logic tags ini

class DetailWidget extends StatefulWidget {
  final Kopi kopi;
  final Function(String ukuran) onTambah;

  const DetailWidget({super.key, required this.kopi, required this.onTambah});

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  String ukuranDipilih = 'Kecil';
  List<String> _komposisiItems = []; // Mengganti nama _fetchedTags untuk kejelasan

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi ini sudah benar untuk memecah string komposisi
  List<String> _generateItemsFromKomposisi(String? komposisiString) {
    if (komposisiString == null || komposisiString.trim().isEmpty) {
      return [];
    }
    // Memecah string berdasarkan koma, membersihkan spasi, dan memfilter item kosong
    return komposisiString
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Langsung proses string 'komposisi' dari widget.kopi saat widget diinisialisasi
    // Tidak perlu fetching lagi jika data komposisi sudah ada di widget.kopi
    _komposisiItems = _generateItemsFromKomposisi(widget.kopi.komposisi);
  }

  // _fetchKopiSpecificTags, _isLoadingTags, _tagsErrorMessage telah dihapus
  // karena kita menggunakan widget.kopi.komposisi secara langsung.

  @override
  Widget build(BuildContext context) {
    final kopi = widget.kopi;

    Widget komposisiSection;
    if (_komposisiItems.isNotEmpty) {
      komposisiSection = Wrap(
        spacing: 8.0, // Jarak horizontal antar tag
        runSpacing: 4.0, // Jarak vertikal jika tag wrap ke baris baru
        children: _komposisiItems.map((item) => _buildKomposisiTag(item)).toList(),
      );
    } else {
      // Tampilkan pesan jika tidak ada item komposisi
      komposisiSection = const Text(
        'Informasi komposisi tidak tersedia.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Scaffold(
      // Hapus Scaffold jika DetailWidget ini adalah bagian dari halaman lain yang sudah punya Scaffold
      // Jika ini adalah halaman penuh, Scaffold bisa tetap ada.
      // Untuk contoh ini, saya asumsikan DetailWidget adalah bagian dari Column di parent, jadi Scaffold di sini mungkin tidak perlu.
      // Jika DetailWidget adalah isi utama dari DetailProdukScreen, maka Scaffold di DetailProdukScreen yang utama.
      // Mari kita anggap ini adalah konten untuk Column, jadi kita kembalikan Padding saja.
      body: SingleChildScrollView( // Tambahkan SingleChildScrollView jika konten bisa melebihi layar
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Komposisi', // Judul untuk bagian komposisi
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            // ),
            // const SizedBox(height: 8),
            komposisiSection,
            const SizedBox(height: 24), // Jarak lebih besar sebelum bagian selanjutnya
            const Text(
              'Ukuran Kopi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 8),
            UkuranGelasWidget(
              onUkuranDipilih: (ukuran) {
                setState(() {
                  ukuranDipilih = ukuran;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Deskripsi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Text(
              kopi.deskripsi,
              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 24), // Padding tambahan di akhir jika perlu
          ],
        ),
      ),
      bottomNavigationBar: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          final sudahAda = keranjangCtrl.sudahAda(widget.kopi, ukuranDipilih);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white, // Warna latar belakang bottom bar
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3), // Bayangan ke atas
                ),
              ],
              // border: Border(top: BorderSide(color: Colors.grey[300]!)) // Garis atas jika diinginkan
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Harga',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      formatRupiah.format(widget.kopi.harga),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (sudahAda) {
                      // Mungkin navigasi ke keranjang atau tampilkan pesan item sudah ada
                      Navigator.pushNamed(context, '/keranjang');
                    } else {
                      Provider.of<KeranjangController>(context, listen: false)
                          .tambah(widget.kopi, ukuranDipilih);
                      // Panggil callback onTambah jika masih diperlukan untuk notifikasi ke parent
                      widget.onTambah(ukuranDipilih);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Tombol lebih rounded
                    ),
                    elevation: 3,
                  ),
                  icon: Icon(sudahAda ? Icons.shopping_cart_checkout : Icons.add_shopping_cart),
                  label: Text(sudahAda ? 'Lihat Keranjang' : 'Tambah', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget untuk membangun setiap tag komposisi
  Widget _buildKomposisiTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(8.0), // Lebih rounded
        border: Border.all(color: Colors.brown.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.brown[700], fontSize: 12),
      ),
    );
  }
}
