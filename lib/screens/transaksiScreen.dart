// screens/periksa_pesanan_screen.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/models/transaksi.dart';
import 'package:kopiqu/screens/struk.dart'; // Pastikan StrukPage diimport
import 'package:kopiqu/widgets/Transaksi/ringkasanPesanan_widget.dart'; // Pastikan widget ini ada
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart'; // Pastikan model Kopi diimport
import 'package:kopiqu/models/keranjang.dart'; // Pastikan model Keranjang diimport
import 'package:intl/intl.dart';
import 'package:kopiqu/services/riwayat_service.dart'; // Service untuk menyimpan riwayat

class PeriksaPesananScreen extends StatefulWidget {
  const PeriksaPesananScreen({super.key});

  @override
  State<PeriksaPesananScreen> createState() => _PeriksaPesananScreenState();
}

class _PeriksaPesananScreenState extends State<PeriksaPesananScreen> {
  final TextEditingController _namaPembeliController = TextEditingController();
  final RiwayatService _riwayatService =
      RiwayatService(); // Instance dari RiwayatService

  // Helper untuk format mata uang
  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id_ID', // Menggunakan id_ID untuk konsistensi dengan locale lain
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  // Method untuk membuat pesanan, kini async untuk menunggu penyimpanan riwayat
  void _buatPesanan(KeranjangController keranjangCtrl) async {
    // Selalu baik untuk mengecek 'mounted' sebelum menampilkan UI atau navigasi dari method async
    // jika ada kemungkinan widget sudah di-dispose saat await selesai.

    // 1. Validasi Nama Pembeli
    if (_namaPembeliController.text.trim().isEmpty) {
      if (mounted) {
        // Cek mounted sebelum menampilkan SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan masukkan nama pembeli'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return; // Hentikan proses jika nama pembeli kosong
    }

    // 2. Ambil Item yang Dipilih dari Keranjang
    final List<KeranjangItem> itemKeranjangDipilih = keranjangCtrl.itemDipilih;

    // 3. Validasi apakah ada item yang dipilih
    if (itemKeranjangDipilih.isEmpty) {
      if (mounted) {
        // Cek mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada item yang dipilih untuk dipesan.'),
            backgroundColor: Colors.orangeAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return; // Hentikan proses jika tidak ada item
    }

    // 4. Konversi item keranjang ke format yang dibutuhkan untuk membuat objek Transaksi
    final List<Map<String, dynamic>> itemYangAkanDipesan =
        itemKeranjangDipilih
            .map(
              (keranjangItem) => {
                'kopi': keranjangItem.kopi,
                'jumlah': keranjangItem.jumlah,
                'ukuran': keranjangItem.ukuran,
                'dipilih':
                    keranjangItem
                        .dipilih, // Meskipun 'dipilih' mungkin tidak digunakan oleh Transaksi.fromKeranjang
              },
            )
            .toList();

    // 5. Buat objek Transaksi
    Transaksi transaksi;
    try {
      transaksi = Transaksi.fromKeranjang(
        keranjangItemsDipilih: itemYangAkanDipesan,
        pembeli: _namaPembeliController.text.trim(),
      );
      print(
        '[PeriksaPesananScreen] Objek Transaksi berhasil dibuat: ${transaksi.id}',
      );
    } catch (e, s) {
      print(
        '[PeriksaPesananScreen] Error saat membuat objek Transaksi: $e\nStacktrace: $s',
      );
      if (mounted) {
        // Cek mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error membuat objek transaksi: $e')),
        );
      }
      return; // Hentikan proses jika pembuatan objek Transaksi gagal
    }

    // 6. Simpan Transaksi ke Riwayat di Supabase (operasi async)
    bool simpanRiwayatBerhasil = false; // Flag untuk status penyimpanan
    try {
      print(
        '[PeriksaPesananScreen] Mencoba menyimpan transaksi ke riwayat Supabase...',
      );
      await _riwayatService.simpanTransaksiKeSupabase(transaksi);
      simpanRiwayatBerhasil = true; // Set flag jika berhasil
      print('[PeriksaPesananScreen] Transaksi berhasil disimpan ke Supabase.');
      if (mounted) {
        // Cek mounted
        // Opsional: Beri feedback singkat bahwa riwayat berhasil disimpan (jika diinginkan)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Pesanan disimpan ke riwayat.'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      print('[PeriksaPesananScreen] GAGAL menyimpan transaksi ke Supabase: $e');
      simpanRiwayatBerhasil = false; // Set flag jika gagal
      if (mounted) {
        // Cek mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pesanan ke riwayat: $e. Struk tetap akan ditampilkan.',
            ),
            backgroundColor: Colors.orange[700], // Warna oranye untuk warning
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // PENTING: Di sini kita TIDAK `return`. Artinya, meskipun gagal simpan riwayat,
      // proses akan tetap lanjut ke pembuatan struk. Ini adalah keputusan desain.
      // Jika Anda ingin proses berhenti jika gagal simpan riwayat, tambahkan `return;` di sini.
    }

    // 7. Navigasi ke Halaman Struk
    // Ini akan dijalankan terlepas dari apakah penyimpanan riwayat berhasil atau tidak (sesuai logika di atas)
    if (mounted) {
      // Cek mounted sebelum navigasi
      print('[PeriksaPesananScreen] Navigasi ke StrukPage...');
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StrukPage(transaksi: transaksi),
            ),
          )
          .then((_) {
            // Logika ini dijalankan setelah pengguna kembali dari StrukPage
            print('[PeriksaPesananScreen] Kembali dari StrukPage.');
            keranjangCtrl
                .bersihkanItemDipilih(); // Bersihkan item yang sudah dipesan

            if (mounted) {
              // Cek mounted sebelum navigasi popUntil
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Kembali ke halaman utama (root)
            }
          })
          .catchError((error, stackTrace) {
            // Menangani error jika terjadi masalah saat navigasi atau di dalam StrukPage itu sendiri
            print(
              '[PeriksaPesananScreen] ERROR saat navigasi/di StrukPage: $error\nStacktrace: $stackTrace',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menampilkan struk: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    }
  }

  @override
  void dispose() {
    _namaPembeliController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kode UI Anda (Scaffold, AppBar, Consumer, Column, Button, dll.)
    // tetap sama seperti yang Anda berikan, tidak ada perubahan di sini.
    // Pastikan Consumer<KeranjangController> mengambil data keranjangCtrl dengan benar.
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
          final List<KeranjangItem> itemKeranjangDipilih =
              keranjangCtrl.itemDipilih;

          final List<Map<String, dynamic>> itemUntukDitampilkan =
              itemKeranjangDipilih
                  .map(
                    (keranjangItem) => {
                      'kopi': keranjangItem.kopi,
                      'jumlah': keranjangItem.jumlah,
                      'ukuran': keranjangItem.ukuran,
                      'dipilih': keranjangItem.dipilih,
                    },
                  )
                  .toList();

          int totalItem = 0;
          for (var keranjangItem in itemKeranjangDipilih) {
            totalItem += keranjangItem.jumlah;
          }

          int subtotal = 0;
          for (var keranjangItem in itemKeranjangDipilih) {
            final kopi =
                keranjangItem
                    .kopi; // Asumsi KeranjangItem.kopi adalah objek Kopi
            final jumlah = keranjangItem.jumlah;
            final ukuran = keranjangItem.ukuran;

            int hargaItem = kopi.harga; // Asumsi Kopi punya field harga
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
                    // Pastikan widget ini ada dan menerima parameter dengan benar
                    namaPembeliController: _namaPembeliController,
                    itemDipilih: itemUntukDitampilkan,
                    totalItem: totalItem,
                    subtotal: subtotal,
                    pajak: pajak,
                    totalPembayaran: totalPembayaran,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                  onPressed:
                      itemUntukDitampilkan.isEmpty
                          ? null
                          : () => _buatPesanan(
                            keranjangCtrl,
                          ), // Memanggil method yang sudah diubah
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
