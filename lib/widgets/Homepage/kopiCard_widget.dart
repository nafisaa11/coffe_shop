// widgets/Homepage/kopiCard_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';
import 'package:shimmer/shimmer.dart'; // 👈 1. PASTIKAN IMPORT SHIMMER ADA

class CoffeeCard extends StatefulWidget {
  final Kopi kopi;
  final void Function(GlobalKey, Kopi) onAddToCartPressed;

  const CoffeeCard({
    super.key,
    required this.kopi,
    required this.onAddToCartPressed,
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
        // LayoutBuilder tetap dipertahankan
        builder: (context, constraints) {
          return Container(
            // Container utama card Anda
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
                    height: constraints.maxWidth * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD3864A),
                        width: 2,
                      ),
                      // 👇 Warna background untuk placeholder shimmer
                      color: Colors.grey.shade300,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Sesuai border container gambar
                      child: Image.network(
                        widget.kopi.gambar,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image_rounded,
                            size: 50,
                            color: Colors.grey.shade400,
                          );
                        },
                        // 👇 2. MODIFIKASI loadingBuilder untuk SHIMMER
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child; // Gambar sudah termuat, tampilkan gambar
                          }
                          // Saat loading, tampilkan efek shimmer
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!, // Warna dasar shimmer
                            highlightColor:
                                Colors.grey[100]!, // Warna highlight shimmer
                            child: Container(
                              // Bentuk placeholder ini harus sama dengan area gambar Anda
                              width: double.infinity,
                              height:
                                  double
                                      .infinity, // Mengisi penuh area ClipRRect
                              color:
                                  Colors
                                      .white, // Warna solid di bawah efek shimmer
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.kopi.nama_kopi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
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
                            fontSize: 14,
                            color: Colors.brown,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 8,
                    bottom: 8,
                    top: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        key: _plusButtonKey,
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
                            color: const Color(0xFFD3864A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22,
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
