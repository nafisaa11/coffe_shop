import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/riwayat_transaksi.dart';
import 'package:kopiqu/screens/struk.dart';
import 'package:kopiqu/services/riwayat_service.dart';
import 'package:kopiqu/screens/riwayat_pembelian_page.dart';

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
    _loadRiwayat();
  }

  void _loadRiwayat() {
    setState(() {
      _futureRiwayatList = _riwayatService.getDaftarRiwayatPengguna();
    });
  }

  String _formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  String _formatTanggal(DateTime tanggal) {
    final now = DateTime.now();
    final difference = now.difference(tanggal).inDays;

    if (difference == 0) {
      return 'Hari ini, ${DateFormat('HH:mm').format(tanggal)}';
    } else if (difference == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(tanggal)}';
    } else if (difference < 7) {
      return '${difference} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(tanggal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFFD07C3D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<RiwayatTransaksi>>(
        future: _futureRiwayatList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD07C3D)),
                  SizedBox(height: 16),
                  Text(
                    'Memuat riwayat pesanan...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Oops! Terjadi kesalahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gagal memuat riwayat pesanan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: _loadRiwayat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.coffee_outlined,
                        size: 64,
                        color: const Color.fromARGB(255, 247, 206, 191),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum Ada Pesanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anda belum memiliki riwayat pesanan.\nMulai pesan kopi favorit Anda!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final List<RiwayatTransaksi> riwayatList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadRiwayat();
            },
            color: Color(0xFFD07C3D),
            child: Column(
              children: [
                // Header info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Color(0xFFD07C3D),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${riwayatList.length} pesanan ditemukan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // List pesanan
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: riwayatList.length,
                    itemBuilder: (context, index) {
                      final riwayatItem = riwayatList[index];

                      String itemSummary = 'Tidak ada item';
                      int totalItems = 0;

                      if (riwayatItem.items.isNotEmpty) {
                        totalItems = riwayatItem.items.length;
                        itemSummary = riwayatItem.items
                            .map(
                              (item) => item['nama_kopi'] as String? ?? 'Item',
                            )
                            .where((nama) => nama.isNotEmpty)
                            .take(2)
                            .join(', ');

                        if (riwayatItem.items.length > 2) {
                          itemSummary +=
                              ' +${riwayatItem.items.length - 2} lainnya';
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => StrukPage(
                                        transaksi:
                                            riwayatItem.toTransaksiModel(),
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon pesanan
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long_outlined,
                                      color: Colors.brown.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Info pesanan
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '#${riwayatItem.nomorStruk}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Selesai',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        Text(
                                          _formatTanggal(
                                            riwayatItem.tanggalTransaksi,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        Text(
                                          '$totalItems item: $itemSummary',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),

                                        Text(
                                          _formatRupiah(
                                            riwayatItem.totalPembayaran,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFD07C3D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow icon
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
