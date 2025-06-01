// widgets/Homepage/grid_homepage_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:lottie/lottie.dart'; // Pastikan Anda sudah menambahkan dependensi lottie di pubspec.yaml

// Import KopiQuColors dari Homepage atau buat file terpisah untuk colors
class KopiQuColors {
  static const Color primary = Color(0xFF8B4513);
  static const Color primaryLight = Color(0xFFD2B48C);
  static const Color secondary = Color(0xFFDEB887);
  static const Color accent = Color(0xFFCD853F);
  static const Color background = Color.fromARGB(255, 255, 255, 255);
  static const Color cardBackground = Color(0xFFFFFAF0);
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color textMuted = Color(0xFF8D6E63);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
}

class GridHomepageWidget extends StatelessWidget {
  final bool isLoadingKopi;
  final String? fetchKopiError;
  final List<Kopi> masterKopiList;
  final List<Kopi> displayedKopiList;
  final String activeTag;
  final VoidCallback onRefresh;
  final Function(GlobalKey, Kopi) onAddToCartPressed;

  const GridHomepageWidget({
    super.key,
    required this.isLoadingKopi,
    required this.fetchKopiError,
    required this.masterKopiList,
    required this.displayedKopiList,
    required this.activeTag,
    required this.onRefresh,
    required this.onAddToCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingKopi) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- AWAL PERUBAHAN: Mengganti CircularProgressIndicator dengan Lottie ---
              SizedBox(
                width: 200, // Sesuaikan ukuran animasi Lottie Anda
                height: 200, // Sesuaikan ukuran animasi Lottie Anda
                child: Lottie.asset(
                  'assets/lottie/Animation-homepage2.json', // PASTIKAN PATH INI BENAR
                  onLoaded: (composition) {
                    print(
                      "Animasi Lottie di GridHomepageWidget (aset) berhasil dimuat.",
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      "Error memuat Lottie di GridHomepageWidget dari aset: $error",
                    );
                    // Fallback jika Lottie gagal dimuat
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: KopiQuColors.primary,
                          backgroundColor: KopiQuColors.primaryLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Memuat menu kopi...',
                          style: TextStyle(
                            color: KopiQuColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Anda mungkin tidak memerlukan teks di bawah Lottie jika animasi sudah cukup informatif
              // Jika tetap ingin ada teks:
              // const SizedBox(height: 16),
              // const Text(
              //   'Memuat menu kopi...',
              //   style: TextStyle(
              //     color: KopiQuColors.textMuted,
              //     fontSize: 16,
              //   ),
              // ),
              // --- AKHIR PERUBAHAN ---
            ],
          ),
        ),
      );
    }

    if (fetchKopiError != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: KopiQuColors.error),
                const SizedBox(height: 16),
                const Text(
                  'Oops! Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: KopiQuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fetchKopiError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: KopiQuColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KopiQuColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (masterKopiList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_cafe_outlined,
                size: 64,
                color: KopiQuColors.textMuted,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Menu Kopi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: KopiQuColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Menu kopi sedang disiapkan untuk Anda',
                style: TextStyle(fontSize: 14, color: KopiQuColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (displayedKopiList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: KopiQuColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Tidak Ada Kopi untuk "$activeTag"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: KopiQuColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coba pilih kategori lain atau kembali lagi nanti',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: KopiQuColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final kopi = displayedKopiList[index];
          return CoffeeCard(
            kopi: kopi,
            onAddToCartPressed: (
              GlobalKey plusButtonKey,
              Kopi kopiUntukKeranjang,
            ) {
              String ukuranPilihan = "Sedang";
              Provider.of<KeranjangController>(
                context,
                listen: false,
              ).tambah(kopiUntukKeranjang, ukuranPilihan);

              onAddToCartPressed(plusButtonKey, kopiUntukKeranjang);

              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${kopiUntukKeranjang.nama_kopi} ditambahkan ke keranjang',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: KopiQuColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        }, childCount: displayedKopiList.length),
      ),
    );
  }
}
