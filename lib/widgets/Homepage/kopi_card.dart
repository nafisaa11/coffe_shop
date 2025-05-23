import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';

class CoffeeCard extends StatelessWidget {
  final Kopi kopi;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  CoffeeCard({super.key, required this.kopi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukScreen(id: kopi.id),
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
                    height: constraints.maxWidth * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD3864A),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        kopi.gambar,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama dan harga
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kopi.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            Text(
                              formatRupiah.format(kopi.harga),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.brown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol add
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, left: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3864A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
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
