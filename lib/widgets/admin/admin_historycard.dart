// lib/widgets/admin/admin_history_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'package:kopiqu/widgets/admin/admin_profilecolor.dart';

class AdminHistoryCard extends StatelessWidget {
  final List<Map<String, dynamic>> loginHistory; // Data riwayat login
  final VoidCallback onViewAllPressed; // Fungsi callback saat tombol "Lihat Semua" ditekan

  const AdminHistoryCard({
    super.key,
    required this.loginHistory,
    required this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Formatter untuk tanggal dan waktu dalam format Indonesia
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: 0, // Tidak ada shadow bawaan Card, diatur manual jika perlu
      color: AdminProfileColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200), // Border tipis
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bagian riwayat login
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AdminProfileColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: AdminProfileColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Riwayat Login Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AdminProfileColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tampilan jika tidak ada riwayat login
            if (loginHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AdminProfileColors.textSecondary),
                    SizedBox(width: 12),
                    Text(
                      'Tidak ada riwayat login yang tercatat.',
                      style: TextStyle(color: AdminProfileColors.textSecondary),
                    ),
                  ],
                ),
              )
            // Tampilan jika ada riwayat login (maksimal 3 item ditampilkan)
            else
              ListView.separated(
                shrinkWrap: true, // Agar ListView menyesuaikan tinggi kontennya
                physics: const NeverScrollableScrollPhysics(), // Non-scrollable di dalam CustomScrollView
                itemCount: loginHistory.length > 3 ? 3 : loginHistory.length, // Tampilkan maks 3
                itemBuilder: (context, index) {
                  final entry = loginHistory[index];
                  final bool isLatest = index == 0; // Tandai item terbaru

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLatest ? AdminProfileColors.accentColor.withOpacity(0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: isLatest ? Border.all(color: AdminProfileColors.accentColor.withOpacity(0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isLatest ? AdminProfileColors.primaryColor : AdminProfileColors.textSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatter.format(entry['timestamp'] as DateTime),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AdminProfileColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry['device'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AdminProfileColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLatest) // Tampilkan badge "Terbaru"
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AdminProfileColors.primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terbaru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12), // Spasi antar item
              ),
          ],
        ),
      ),
    );
  }
}