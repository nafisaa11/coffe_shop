// screens/periksa_pesanan_screen.dart
import 'dart:ui'; // Untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/keranjang/KeranjangBase_Controller.dart';
import 'package:kopiqu/models/transaksi.dart'; // Pastikan path ini benar
import 'package:kopiqu/screens/pembeli/struk.dart'; // Pastikan path ini benar
import 'package:kopiqu/widgets/Transaksi/ringkasanPesanan_widget.dart'; // Pastikan path ini benar
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar
import 'package:kopiqu/models/keranjang.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart';
import 'package:kopiqu/services/riwayat_service.dart'; // Pastikan path ini benar
import 'package:lottie/lottie.dart'; // Untuk animasi Lottie

class PeriksaPesananScreen extends StatefulWidget {
  const PeriksaPesananScreen({super.key});

  @override
  State<PeriksaPesananScreen> createState() => _PeriksaPesananScreenState();
}

class _PeriksaPesananScreenState extends State<PeriksaPesananScreen> {
  final TextEditingController _namaPembeliController = TextEditingController();
  final RiwayatService _riwayatService = RiwayatService();
  bool _isProcessingOrder = false;

  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  void _buatPesanan(KeranjangController keranjangCtrl) async {
    if (!mounted) return;

    // 1. Validasi Nama Pembeli
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

    // 2. Ambil Item yang Dipilih dari Keranjang
    final List<KeranjangItem> itemKeranjangDipilih = keranjangCtrl.itemDipilih;

    // 3. Validasi apakah ada item yang dipilih
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

    // Tampilkan loading overlay
    setState(() {
      _isProcessingOrder = true;
    });

    // Delay artifisial (opsional, untuk memastikan animasi Lottie terlihat)
    await Future.delayed(const Duration(seconds: 2));

    // 4. Konversi item keranjang
    final List<Map<String, dynamic>> itemYangAkanDipesan =
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

    // 5. Buat objek Transaksi
    Transaksi? transaksi;
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
        '[PeriksaPesananScreen] Error saat membuat objek Transaksi: $e\n$s',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error membuat detail pesanan: $e')),
        );
        setState(() {
          _isProcessingOrder = false;
        });
      }
      return;
    }

    // Pengecekan tambahan jika transaksi null (seharusnya tidak terjadi jika try-catch di atas berjalan)
    if (transaksi == null) {
      if (mounted)
        setState(() {
          _isProcessingOrder = false;
        });
      return;
    }

    // 6. Simpan Transaksi ke Riwayat di Supabase
    bool riwayatBerhasilDisimpan = false;
    try {
      await _riwayatService.simpanTransaksiKeSupabase(transaksi);
      riwayatBerhasilDisimpan = true;
      print('[PeriksaPesananScreen] Transaksi disimpan ke riwayat.');
    } catch (e) {
      print('[PeriksaPesananScreen] GAGAL simpan riwayat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pesanan ke riwayat: $e. Struk tetap akan ditampilkan.',
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
      // Proses tetap lanjut ke struk meskipun simpan riwayat gagal
    }

    // 7. Bersihkan item yang dipilih dari keranjang (Supabase dan lokal)
    // Ini dilakukan setelah transaksi dibuat dan riwayat (dicoba) disimpan.
    // Method bersihkanItemDipilihDariSupabase() di KeranjangController akan menghapus
    // item yang 'dipilih:true' dari tabel 'keranjang' di Supabase dan me-refresh state lokal.
    try {
      print(
        '[PeriksaPesananScreen] Membersihkan item yang dipilih dari keranjang...',
      );
      keranjangCtrl.bersihkanItemDipilih();
      print(
        '[PeriksaPesananScreen] Item yang dipilih telah dibersihkan dari keranjang.',
      );
    } catch (e) {
      print('[PeriksaPesananScreen] Gagal membersihkan item keranjang: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membersihkan keranjang setelah pesan: $e'),
          ),
        );
      }
      // Proses tetap lanjut ke struk
    }

    if (!mounted) return;

    // Matikan loading overlay sebelum navigasi
    setState(() {
      _isProcessingOrder = false;
    });

    // 8. Navigasi ke Halaman Struk menggunakan pushReplacement
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StrukPage(transaksi: transaksi!)),
    ).catchError((error, stackTrace) {
      print(
        '[PeriksaPesananScreen] ERROR saat navigasi/di StrukPage: $error\n$stackTrace',
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

  @override
  void dispose() {
    _namaPembeliController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Consumer<KeranjangController>(
      builder: (context, keranjangCtrl, _) {
        final List<KeranjangItem> itemKeranjangDipilih =
            keranjangCtrl.itemDipilih;
        final List<Map<String, dynamic>> itemUntukDitampilkan =
            itemKeranjangDipilih
                .map(
                  (item) => {
                    'kopi': item.kopi,
                    'jumlah': item.jumlah,
                    'ukuran': item.ukuran,
                    'dipilih': item.dipilih,
                  },
                )
                .toList();

        int totalItem = 0;
        for (var item in itemKeranjangDipilih) {
          totalItem += item.jumlah;
        }
        int subtotal = 0;
        for (var item in itemKeranjangDipilih) {
          final Kopi kopi = item.kopi;
          int hargaItem = kopi.harga;
          if (item.ukuran == 'Besar') {
            hargaItem += 5000;
          } else if (item.ukuran == 'Kecil') {
            hargaItem -= 3000;
            if (hargaItem < 0) hargaItem = 0;
          }
          subtotal += hargaItem * item.jumlah;
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
            if (!_isProcessingOrder) // Tombol hanya tampil jika tidak sedang loading
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
                      itemUntukDitampilkan.isEmpty || _isProcessingOrder
                          ? null
                          : () => _buatPesanan(keranjangCtrl),
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
    );

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
          onPressed: () => _isProcessingOrder ? null : Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          mainContent, // Konten utama (form, ringkasan)
          if (_isProcessingOrder) // Overlay loading hanya tampil jika _isProcessingOrder true
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 120, // Sesuaikan ukuran Lottie
                            height: 120,
                            child: Lottie.asset(
                              'assets/lottie/Animation-pesanan.json', // Path Lottie Anda
                              onLoaded: (composition) {
                                print(
                                  "Animasi Lottie di PeriksaPesananScreen (overlay) berhasil dimuat.",
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  "Error memuat Lottie di PeriksaPesananScreen (overlay): $error",
                                );
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF8D6E63),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Pesanan Diproses...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'Mohon tunggu sebentar, pesanan Anda sedang kami siapkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}