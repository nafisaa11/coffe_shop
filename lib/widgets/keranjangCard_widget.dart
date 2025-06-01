// widgets/keranjang_card_widget.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/models/keranjang.dart';
import 'package:kopiqu/models/kopi.dart'; // Untuk tipe Kopi
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class KeranjangCardWidget extends StatelessWidget {
  final KeranjangItem item; // Menerima satu objek KeranjangItem

  const KeranjangCardWidget({super.key, required this.item});

  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  // Fungsi untuk menghitung harga berdasarkan ukuran
  int getHargaByUkuran(Kopi kopi, String ukuran) {
    int hargaAsli = kopi.harga;
    switch (ukuran.toLowerCase()) {
      case 'kecil':
        return hargaAsli;
      case 'sedang':
        return hargaAsli + 3000;
      case 'besar':
        return hargaAsli + 5000;
      default:
        return hargaAsli;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keranjangCtrl = Provider.of<KeranjangController>(
      context,
      listen: false,
    );

    // Mengambil data dari objek item untuk kemudahan
    final Kopi kopi = item.kopi;
    final String currentUkuran =
        item.ukuran; // Gunakan nama variabel berbeda untuk menghindari kebingungan di closure
    final int jumlah = item.jumlah;
    final bool dipilih = item.dipilih;

    // Hitung harga berdasarkan ukuran yang dipilih
    final int hargaPerItem = getHargaByUkuran(kopi, currentUkuran);
    final int totalHargaItem = hargaPerItem * jumlah;

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: dipilih,
            onChanged:
                (_) => keranjangCtrl.togglePilihDiSupabase(kopi, currentUkuran),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.brown.shade100),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        kopi.gambar.startsWith('http')
                            ? Image.network(
                              kopi.gambar,
                              width: 80,
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                            : Image.asset(
                              // Fallback jika bukan URL
                              kopi.gambar, // Pastikan path ini ada di assets jika digunakan
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                kopi.nama_kopi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () =>
                                      keranjangCtrl.hapus(kopi, currentUkuran),
                              child: const CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                radius: 14, // Sedikit lebih kecil
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Dropdown untuk mengubah ukuran dengan tampilan harga
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.brown[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: currentUkuran,
                            isDense: true,
                            underline:
                                const SizedBox(), // Hilangkan underline default
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.brown[600],
                            ),
                            items:
                                ['Kecil', 'Sedang', 'Besar'].map((
                                  String ukuran,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: ukuran,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ukuran,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newUkuran) {
                              if (newUkuran != null &&
                                  newUkuran != currentUkuran) {
                                keranjangCtrl.ubahUkuran(
                                  kopi,
                                  currentUkuran,
                                  newUkuran,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                // Tampilkan total harga
                                Text(
                                  formatRupiah(totalHargaItem),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.brown,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap:
                                      () => keranjangCtrl.ubahJumlah(
                                        kopi,
                                        currentUkuran,
                                        -1,
                                      ),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.brown[300]!,
                                        width: 1,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: Colors.brown[700],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    '$jumlah',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap:
                                      () => keranjangCtrl.ubahJumlah(
                                        kopi,
                                        currentUkuran,
                                        1,
                                      ),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.brown,
                                      border: Border.all(
                                        color: Colors.brown[700]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
