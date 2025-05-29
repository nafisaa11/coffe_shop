import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk formatting tanggal dan mata uang
import 'package:kopiqu/models/riwayat_transaksi.dart'; 
import 'package:kopiqu/screens/struk.dart';
import 'package:kopiqu/services/riwayat_service.dart'; // Service untuk ambil data
import 'package:kopiqu/screens/riwayat_pembelian_page.dart'; // Halaman detail riwayat Anda


// Halaman ini akan menampilkan daftar semua riwayat transaksi pengguna.
class DaftarRiwayatPage extends StatefulWidget {
  const DaftarRiwayatPage({super.key});

  @override
  State<DaftarRiwayatPage> createState() => _DaftarRiwayatPageState();
}

class _DaftarRiwayatPageState extends State<DaftarRiwayatPage> {
  final RiwayatService _riwayatService = RiwayatService();
  late Future<List<RiwayatTransaksi>> _futureRiwayatList;

  @override
  void initState() {
    super.initState();
    _loadRiwayat(); // Panggil method untuk memuat data saat halaman pertama kali dibuka
  }

  // Method untuk memuat atau memuat ulang data riwayat
  void _loadRiwayat() {
    setState(() {
      _futureRiwayatList = _riwayatService.getDaftarRiwayatPengguna();
    });
  }

  // Helper untuk format mata uang
  String _formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan Saya'),
        backgroundColor: Colors.brown.shade400, // Sesuaikan warna
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<RiwayatTransaksi>>(
        future: _futureRiwayatList,
        builder: (context, snapshot) {
          // Tampilkan loading indicator saat data sedang diambil
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Tampilkan pesan error jika terjadi kesalahan
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gagal memuat riwayat: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _loadRiwayat,
                    ),
                  ],
                ),
              ),
            );
          }
          // Tampilkan pesan jika tidak ada data riwayat atau data kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Anda belum memiliki riwayat pesanan.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Jika data berhasil diambil dan tidak kosong
          final List<RiwayatTransaksi> riwayatList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadRiwayat(); // Implementasi pull-to-refresh
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: riwayatList.length,
              itemBuilder: (context, index) {
                final riwayatItem = riwayatList[index];

                // Membuat ringkasan item, contoh: "Kopi A, Kopi B..."
                String itemSummary = 'Tidak ada item detail';
                if (riwayatItem.items.isNotEmpty) {
                  itemSummary = riwayatItem.items
                      .map(
                        (item) =>
                            item['nama_kopi'] as String? ??
                            'Item tidak dikenal',
                      )
                      .where((nama) => nama.isNotEmpty)
                      .join(', ');
                  if (itemSummary.length > 40)
                    itemSummary = "${itemSummary.substring(0, 40)}...";
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 8.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown.shade100,
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.brown.shade700,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Pesanan: ${riwayatItem.nomorStruk}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          // Format tanggal menjadi lebih mudah dibaca
                          DateFormat(
                            'EEEE, dd MMMM yyyy, HH:mm',
                            'id_ID',
                          ).format(riwayatItem.tanggalTransaksi),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Item: $itemSummary',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${_formatRupiah(riwayatItem.totalPembayaran)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    isThreeLine: false, // Sesuaikan jika perlu
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StrukPage(
                                // 🎯 Navigasi ke StrukPage
                                transaksi:
                                    riwayatItem
                                        .toTransaksiModel(), 
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
