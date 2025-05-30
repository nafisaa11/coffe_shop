import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk formatting harga
import 'package:kopiqu/models/kopi.dart'; // Pastikan path ini benar

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

    // Ambil warna dari tema. primaryColorDark dijamin ada nilainya.
    final Color hargaColor = Theme.of(context).primaryColorDark;
    // Jika Anda secara spesifik ingin warna coklat tua untuk harga, dan tidak mau tergantung tema:
    // final Color hargaColor = Colors.brown[700]!; // atau const Color(0xFF4E342E);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                kopiItem.gambar,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    // Anda mengubah warna errorBuilder ke putih, mungkin lebih baik tetap abu-abu
                    color:
                        Colors
                            .grey[200], // Atau const Color.fromARGB(255, 255, 255, 255)
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    // Warna loading placeholder Anda (0xFF804E23) adalah coklat tua, mungkin cocok
                    color: const Color(
                      0xFFE0E0E0,
                    ), // Atau const Color(0xFF804E23) jika itu preferensi Anda
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ), // Warna progress indicator
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
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
                  Text(
                    kopiItem.nama_kopi,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Warna teks nama kopi
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(kopiItem.harga),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          hargaColor, // Menggunakan warna yang sudah diambil dari tema
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent[700],
                        size: 22,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Edit Menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent[700],
                        size: 22,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Hapus Menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
