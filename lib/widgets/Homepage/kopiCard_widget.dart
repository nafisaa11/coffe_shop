import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';

class CoffeeCard extends StatefulWidget {
  final Kopi kopi;
  final void Function(GlobalKey, Kopi) onAddToCartPressed;

  const CoffeeCard({
    super.key,
    required this.kopi,
    required this.onAddToCartPressed, // Tambahkan parameter ini di constructor
  });

  @override
  State<CoffeeCard> createState() => _CoffeeCardState();
}

class _CoffeeCardState extends State<CoffeeCard> {
  final GlobalKey _plusButtonKey = GlobalKey();

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukScreen(id: widget.kopi.id),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7E9DE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD3864A)),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gambar
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Container(
                    height:
                        constraints.maxWidth *
                        0.7, // Tinggi gambar relatif terhadap lebar card
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD3864A),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.kopi.gambar, // Gunakan URL dari widget.kopi
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image_rounded,
                            size: 50,
                            color: Colors.grey.shade400,
                          );
                        },
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              strokeWidth: 2.0,
                              color: Colors.brown,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Expanded agar teks dan harga mengisi sisa ruang sebelum tombol plus
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center, // Pusatkan teks jika ada sisa ruang
                      children: [
                        Text(
                          widget.kopi.nama_kopi,
                          maxLines: 2, // Izinkan 2 baris untuk nama kopi
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15, // Sedikit lebih kecil agar muat
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah.format(widget.kopi.harga),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14, // Sedikit lebih kecil
                            color: Colors.brown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol Add dan Harga
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 8,
                    bottom: 8,
                    top: 4,
                  ), // Sesuaikan padding
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Tombol plus di kanan
                    children: [
                      InkWell(
                        key: _plusButtonKey, // Pasang GlobalKey di sini
                        onTap: () {
                          print(
                            '[CoffeeCard] Tombol plus untuk "${widget.kopi.nama_kopi}" ditekan.',
                          );
                          widget.onAddToCartPressed(
                            _plusButtonKey,
                            widget.kopi,
                          );
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3864A), // Warna tombol
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(
                            8,
                          ), // Padding ikon di dalam lingkaran
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22, // Ukuran ikon
                          ),
                        ),
                      ),
                    ],
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
