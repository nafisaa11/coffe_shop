// lib/widgets/admin/admin_menucard.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';

const Color kCafeDarkBrown = Color(0xFF4D2F15);
const Color kCafeMediumBrown = Color(0xFFB06C30);
const Color kCafeLightBrown = Color(0xFFE3B28C);
const Color kCafeVeryLightBeige = Color(0xFFF7E9DE);
const Color kCafeTextBlack = Color(0xFF1D1616);
const Color kNewLabelColor = Colors.redAccent; // Warna untuk label "Baru"

class AdminMenuItemCard extends StatelessWidget {
  final Kopi kopiItem;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminMenuItemCard({
    super.key,
    required this.kopiItem,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    bool isNewItem = false;
    if (kopiItem.createdAt != null) {
      // Item dianggap "baru" jika ditambahkan dalam 3 hari terakhir (0, 1, atau 2 hari yang lalu)
      final difference = DateTime.now().difference(kopiItem.createdAt!);
      if (difference.inDays <= 2) {
        isNewItem = true;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Shadow lebih halus
            spreadRadius: 0.5,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Slidable(
        key: ValueKey(kopiItem.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(), // DrawerMotion lebih smooth
          extentRatio: 0.3, // Luas area aksi saat digeser
          children: [
            // Custom circular edit button
            if (onEdit != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5), // Margin disesuaikan
                  child: InkWell(
                    onTap: () => onEdit!(),
                    borderRadius: BorderRadius.circular(50), // Untuk efek ripple
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCafeMediumBrown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kCafeDarkBrown.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 22, // Ukuran ikon disesuaikan
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Custom circular delete button
            if (onDelete != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: InkWell(
                    onTap: () => onDelete!(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F), // Warna merah lebih standar
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_forever_rounded, // Ikon hapus yang lebih tegas
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        child: ClipRRect( // Tambahkan ClipRRect di sini untuk memotong child sesuai border radius
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(15), // Tidak perlu jika sudah di ClipRRect luar
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Padding internal card
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image container dengan Stack untuk label "Baru"
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 0.5,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            kopiItem.gambar.isNotEmpty 
                                ? kopiItem.gambar 
                                : 'https://via.placeholder.com/150/F7E9DE/4D2F15?text=KopiQu', // URL placeholder
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container( /* ... error builder Anda ... */ );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              /* ... loading builder Anda ... */
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(color: kCafeVeryLightBeige, borderRadius: BorderRadius.circular(12.0)),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(kCafeMediumBrown))),
                              );
                            },
                          ),
                        ),
                      ),
                      // Label "Baru" jika item baru
                      if (isNewItem)
                        Positioned(
                          top: 0, // Posisi di atas kiri
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: kNewLabelColor, // Warna label "Baru"
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(1,1)
                                )
                              ]
                            ),
                            child: const Text(
                              'Baru!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Konten (Nama, Komposisi, Harga)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          kopiItem.nama_kopi,
                          style: const TextStyle(
                            fontSize: 16, // Ukuran font disesuaikan
                            fontWeight: FontWeight.bold,
                            color: kCafeTextBlack,
                            height: 1.3, // Line height
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          kopiItem.komposisi.isNotEmpty 
                              ? kopiItem.komposisi 
                              : 'Komposisi tidak tersedia',
                          style: TextStyle(
                            fontSize: 12,
                            color: kCafeTextBlack.withOpacity(0.65), // Kontras lebih baik
                            height: 1.3,
                          ),
                          maxLines: 2, // Izinkan 2 baris untuk komposisi
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          currencyFormatter.format(kopiItem.harga),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700, // Sedikit lebih tebal
                            color: kCafeDarkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8), // Beri sedikit jarak sebelum indikator geser
                  
                  // Indikator Geser
                  Container(
                    padding: const EdgeInsets.all(4), // Padding lebih kecil
                    // decoration: BoxDecoration( // Hapus background jika terlalu ramai
                    //   color: kCafeLightBrown.withOpacity(0.1),
                    //   borderRadius: BorderRadius.circular(20),
                    // ),
                    child: Icon(
                      Icons.chevron_left_rounded, // Ikon yang lebih menunjukkan arah geser dari kanan
                      color: kCafeMediumBrown.withOpacity(0.7),
                      size: 22, // Ukuran ikon disesuaikan
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}