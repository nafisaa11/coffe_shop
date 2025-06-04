// widgets/alert_konfirmasi_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertKonfirmasiWidget {
  /// Method untuk menampilkan dialog konfirmasi pemesanan
  /// 
  /// Parameters:
  /// - [context]: BuildContext untuk menampilkan dialog
  /// - [namaPembeli]: Nama pembeli yang akan ditampilkan
  /// - [totalItem]: Total item yang dipesan
  /// - [totalPembayaran]: Total pembayaran yang harus dibayar
  /// 
  /// Returns:
  /// - [Future<bool>]: true jika user mengkonfirmasi, false jika membatalkan
  static Future<bool> showKonfirmasiPesanan({
    required BuildContext context,
    required String namaPembeli,
    required int totalItem,
    required int totalPembayaran,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User harus memilih salah satu opsi
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFFAF0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Colors.brown,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Konfirmasi Pesanan',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin melakukan pemesanan dengan detail berikut?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nama Pembeli:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.brown,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            namaPembeli,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Item:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.brown,
                          ),
                        ),
                        Text(
                          '$totalItem item',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.brown,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatRupiah(totalPembayaran),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Pesanan yang sudah dikonfirmasi tidak dapat dibatalkan.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User memilih "Batal"
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User memilih "Ya, Pesan"
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Pesan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false; // Jika dialog ditutup tanpa memilih, return false
  }

  /// Method untuk menampilkan dialog konfirmasi dengan opsi kustomisasi lebih lanjut
  /// 
  /// Parameters:
  /// - [context]: BuildContext untuk menampilkan dialog
  /// - [title]: Judul dialog (default: 'Konfirmasi Pesanan')
  /// - [message]: Pesan utama dialog
  /// - [namaPembeli]: Nama pembeli
  /// - [totalItem]: Total item
  /// - [totalPembayaran]: Total pembayaran
  /// - [warningText]: Teks peringatan (default: 'Pesanan yang sudah dikonfirmasi tidak dapat dibatalkan.')
  /// - [cancelButtonText]: Teks tombol batal (default: 'Batal')
  /// - [confirmButtonText]: Teks tombol konfirmasi (default: 'Ya, Pesan')
  /// - [iconData]: Icon untuk header (default: Icons.help_outline)
  /// 
  /// Returns:
  /// - [Future<bool>]: true jika user mengkonfirmasi, false jika membatalkan
  static Future<bool> showKustomKonfirmasi({
    required BuildContext context,
    String title = 'Konfirmasi Pesanan',
    String message = 'Apakah Anda yakin ingin melakukan pemesanan dengan detail berikut?',
    required String namaPembeli,
    required int totalItem,
    required int totalPembayaran,
    String warningText = 'Pesanan yang sudah dikonfirmasi tidak dapat dibatalkan.',
    String cancelButtonText = 'Batal',
    String confirmButtonText = 'Ya, Pesan',
    IconData iconData = Icons.help_outline,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                iconData,
                color: Colors.brown,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Nama Pembeli:', namaPembeli),
                    const SizedBox(height: 8),
                    _buildDetailRow('Total Item:', '$totalItem item'),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Total Pembayaran:', 
                      _formatRupiah(totalPembayaran),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                warningText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                cancelButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                confirmButtonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Helper method untuk membuat row detail
  static Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.brown,
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown,
              fontSize: isHighlight ? 16 : 14,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Helper method untuk format rupiah
  static String _formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }
}