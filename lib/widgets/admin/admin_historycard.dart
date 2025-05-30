import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class LoginHistoryCard extends StatelessWidget {
  // Anda akan memerlukan model data untuk riwayat login
  // Untuk sekarang, kita buat data dummy
  final List<Map<String, dynamic>>
  loginHistory; // Contoh: [{'timestamp': DateTime, 'device': 'Android'}]
  final Color cardBackgroundColor;
  final Color textColor;

  const LoginHistoryCard({
    super.key,
    required this.loginHistory,
    this.cardBackgroundColor = Colors.white,
    this.textColor = const Color(0xFF4E342E), // Coklat Tua
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat(
      'dd MMM yyyy, HH:mm',
      'id_ID',
    ); // Format tanggal Indonesia

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Login Terakhir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (loginHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Tidak ada riwayat login yang tercatat.',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    loginHistory.length > 5
                        ? 3
                        : loginHistory.length, // Tampilkan maks 5 entri
                itemBuilder: (context, index) {
                  final entry = loginHistory[index];
                  return ListTile(
                    leading: Icon(
                      Icons.login,
                      color: textColor.withOpacity(0.7),
                      size: 20,
                    ),
                    title: Text(
                      formatter.format(entry['timestamp'] as DateTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Perangkat: ${entry['device']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    dense: true,
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
              ),
            if (loginHistory.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman riwayat login penuh
                    },
                    child: Text(
                      'Lihat Semua Riwayat',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
