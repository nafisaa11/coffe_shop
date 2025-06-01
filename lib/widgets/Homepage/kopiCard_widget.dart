// widgets/Homepage/kopiCard_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/screens/detailProdukScreen.dart';
import 'package:shimmer/shimmer.dart';

// Warna tema yang konsisten untuk KopiQu
class KopiQuColors {
  static const Color primary = Color(0xFF8B4513); // Saddle Brown - warna utama kopi
  static const Color primaryLight = Color(0xFFD2B48C); // Tan - warna kopi muda
  static const Color secondary = Color(0xFFDEB887); // Burlywood - warna sekunder
  static const Color accent = Color(0xFFCD853F); // Peru - warna aksen
  static const Color background = Color(0xFFFAF0E6); // Linen - background lembut
  static const Color cardBackground = Color(0xFFFFFAF0); // FloralWhite - background card
  static const Color textPrimary = Color(0xFF3E2723); // Dark Brown - teks utama
  static const Color textSecondary = Color(0xFF5D4037); // Brown - teks sekunder
  static const Color textMuted = Color(0xFF8D6E63); // Brown Grey - teks muted
  static const Color newLabel = Color(0xFFE65100); // Deep Orange - label baru
  static const Color shadow = Color(0x1A8B4513); // Shadow dengan opacity
}

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

class _CoffeeCardState extends State<CoffeeCard> with SingleTickerProviderStateMixin {
  final GlobalKey _plusButtonKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get isNewProduct {
    if (widget.kopi.createdAt != null) {
      final difference = DateTime.now().difference(widget.kopi.createdAt!);
      return difference.inDays <= 2;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProdukScreen(id: widget.kopi.id),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: KopiQuColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: KopiQuColors.primaryLight.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: KopiQuColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section Gambar dengan Label "Baru"
                  _buildImageSection(),
                  
                  // Section Informasi Produk
                  _buildProductInfo(),
                  
                  // Section Harga dan Tombol
                  _buildBottomSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.only(
              //     color: KopiQuColors.primaryLight.withOpacity(0.5),
              //     width: 1,
              //   ),
              //   color: KopiQuColors.background,
              // ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  widget.kopi.gambar.isNotEmpty 
                      ? widget.kopi.gambar 
                      : 'https://via.placeholder.com/200x200/FAF0E6/8B4513?text=KopiQu',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: KopiQuColors.background,
                      child: Icon(
                        Icons.local_cafe_outlined,
                        size: 48,
                        color: KopiQuColors.textMuted,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: KopiQuColors.background,
                      highlightColor: Colors.white,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: KopiQuColors.background,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Label "Baru"
          if (isNewProduct)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: KopiQuColors.newLabel,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'BARU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Kopi
            Text(
              widget.kopi.nama_kopi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: KopiQuColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            
            // Komposisi/Deskripsi
            Expanded(
              child: Text(
                widget.kopi.komposisi.isNotEmpty 
                    ? widget.kopi.komposisi 
                    : 'Kopi pilihan premium dengan cita rasa istimewa',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: KopiQuColors.textMuted,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          // Harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  formatRupiah.format(widget.kopi.harga),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: KopiQuColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Tombol Add to Cart
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: _plusButtonKey,
              onTap: () {
                print('[CoffeeCard] Menambahkan "${widget.kopi.nama_kopi}" ke keranjang');
                widget.onAddToCartPressed(_plusButtonKey, widget.kopi);
              },
              borderRadius: BorderRadius.circular(12),
              splashColor: KopiQuColors.primary.withOpacity(0.2),
              highlightColor: KopiQuColors.primary.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KopiQuColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: KopiQuColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_shopping_cart_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}