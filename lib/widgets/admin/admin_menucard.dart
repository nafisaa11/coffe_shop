import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk formatting harga
import 'package:kopiqu/models/kopi.dart'; // <-- UBAH IMPORT ke model Kopi Anda (pastikan path benar)

class AdminMenuItemCard extends StatelessWidget {
  final Kopi kopiItem; // <-- UBAH TIPE menjadi Kopi
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminMenuItemCard({
    super.key,
    required this.kopiItem, // <-- UBAH TIPE menjadi Kopi
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

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Ubah ke start agar gambar dan teks sejajar atas
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                kopiItem.gambar, // <-- GUNAKAN kopiItem.gambar
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
                // mainAxisAlignment: MainAxisAlignment.center, // Hapus ini agar teks mulai dari atas
                children: [
                  Text(
                    kopiItem.nama_kopi, // <-- GUNAKAN kopiItem.nama_kopi
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Anda bisa menampilkan deskripsi atau komposisi di sini jika mau
                  // if (kopiItem.deskripsi.isNotEmpty) ...
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(kopiItem.harga), // <-- GUNAKAN kopiItem.harga (tipe int)
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColorDark ?? Colors.brown[700],
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
                      icon: Icon(Icons.edit_outlined, color: Colors.blue[700], size: 22),
                      onPressed: onEdit,
                      tooltip: 'Edit Menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 22),
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