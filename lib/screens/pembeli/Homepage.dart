// screens/Homepage.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Untuk Random
import 'package:kopiqu/controllers/Banner_Controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/banner_slider.dart';
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart';
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart'; // 👈 1. IMPORT LOTTIE

// Warna tema yang konsisten (sama dengan yang di CoffeeCard)
class KopiQuColors {
  // Pastikan class ini didefinisikan atau diimport jika terpisah
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

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  final bannerImages = [
    'assets/baner1.jpg',
    'assets/baner2.jpg',
    'assets/baner3.jpg',
    'assets/baner4.jpg',
    'assets/baner5.jpg',
  ];
  final BannerController bannerController = BannerController();
  final supabase = Supabase.instance.client;

  List<Kopi> _masterKopiList = [];
  List<Kopi> _displayedKopiList = [];
  bool _isLoadingKopi = true;
  String? _fetchKopiError;
  String _activeTag = TagList.tagRekomendasi;

  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    fetchKopi();
    bannerController.startAutoScroll(bannerImages, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    _animationController?.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> fetchKopi() async {
    if (!mounted) return;
    setState(() {
      _isLoadingKopi = true;
      _fetchKopiError = null;
    });
    try {
      final response = await supabase.from('kopi').select().order('id');
      if (mounted) {
        _masterKopiList = Kopi.listFromJson(response as List<dynamic>);
        _applyTagFilter();
        setState(() {
          _isLoadingKopi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingKopi = false;
          _fetchKopiError = "Gagal memuat data kopi: ${e.toString()}";
        });
        print("Error fetching kopi on homepage: $e");
      }
    }
  }

  void _onTagSelected(String tagName) {
    if (!mounted) return;
    setState(() {
      _activeTag = tagName;
      _applyTagFilter();
    });
  }

  void _applyTagFilter() {
    List<Kopi> tempList = [];
    if (_activeTag == TagList.tagRekomendasi) {
      if (_masterKopiList.isNotEmpty) {
        final random = Random();
        List<Kopi> shuffledList = List.from(_masterKopiList)..shuffle(random);
        tempList = shuffledList.take(6).toList();
      }
    } else if (_activeTag == TagList.tagPalingMurah) {
      if (_masterKopiList.isNotEmpty) {
        List<Kopi> sortedList = List.from(_masterKopiList)
          ..sort((a, b) => a.harga.compareTo(b.harga));
        tempList = sortedList.take(6).toList();
      }
    } else {
      if (_masterKopiList.isNotEmpty) {
        final random = Random();
        List<Kopi> shuffledList = List.from(_masterKopiList)..shuffle(random);
        tempList = shuffledList.take(6).toList();
      }
    }
    if (mounted) {
      setState(() {
        _displayedKopiList = tempList;
      });
    }
  }

  void _mulaiAnimasiTambahKeKeranjang(
    GlobalKey tombolPlusKeyDariCard,
    Kopi kopiYangDitambahkan,
  ) {
    // ... (KODE METHOD INI TETAP SAMA PERSIS) ...
    final cartUiService = Provider.of<CartUIService>(context, listen: false);
    cartUiService.updateCartIconPosition();
    final Offset? posisiAkhirKeranjang = cartUiService.cartIconPosition;

    if (tombolPlusKeyDariCard.currentContext == null ||
        posisiAkhirKeranjang == null) {
      print(
        "[Homepage] Gagal memulai animasi: key atau posisi keranjang tidak valid.",
      );
      String ukuranPilihan = "Sedang";
      Provider.of<KeranjangController>(
        context,
        listen: false,
      ).tambah(kopiYangDitambahkan, ukuranPilihan);
      return;
    }

    final RenderBox tombolRenderBox =
        tombolPlusKeyDariCard.currentContext!.findRenderObject() as RenderBox;
    final Offset posisiAwalTombol = tombolRenderBox.localToGlobal(Offset.zero);
    final Offset posisiAwalAnimasi =
        posisiAwalTombol +
        Offset(
          tombolRenderBox.size.width / 2,
          tombolRenderBox.size.height / 2 - 10,
        );

    _overlayEntry?.remove();
    _animationController?.dispose();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: posisiAwalAnimasi,
      end: posisiAkhirKeranjang,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOutCubic,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            if (_slideAnimation == null ||
                _scaleAnimation == null ||
                !_animationController!.isAnimating &&
                    _animationController!.status != AnimationStatus.forward) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: _slideAnimation!.value.dx,
              top: _slideAnimation!.value.dy,
              child: Transform.scale(
                scale: _scaleAnimation!.value,
                child: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 1.0 - (_animationController!.value * 0.5),
                    child: Container(
                      // Menggunakan Container dari kode animasi login Anda
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: KopiQuColors.success, // Menggunakan warna tema
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: KopiQuColors.success.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _animationController?.dispose();
        _animationController = null;
      }
    });
    _animationController!.forward();
  }

  Widget _buildProductsGrid() {
    // Method ini sudah ada di kode Anda
    if (_isLoadingKopi) {
      // 👇 2. GANTI CircularProgressIndicator DENGAN LOTTIE ANIMATION
      return SliverFillRemaining(
        child: Center(
          child: SizedBox(
            // Beri ukuran pada Lottie
            width:
                500, // Sesuaikan ukuran Lottie Anda sama seperti di LoginPage
            height: 500,
            child: Lottie.asset(
              'assets/lottie/Animation-hoomepage2.json', // PASTIKAN PATH INI BENAR
              onLoaded: (composition) {
                print("Animasi Lottie di Homepage (aset) berhasil dimuat.");
              },
              errorBuilder: (context, error, stackTrace) {
                print("Error memuat Lottie di Homepage dari aset: $error");
                // Fallback jika Lottie gagal
                return CircularProgressIndicator(
                  color: KopiQuColors.primary, // Menggunakan warna tema
                  backgroundColor: KopiQuColors.primaryLight,
                );
              },
            ),
          ),
        ),
      );
    }

    if (_fetchKopiError != null) {
      // ... (UI Error Anda sudah baik) ...
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
                  _fetchKopiError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: KopiQuColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: fetchKopi,
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

    if (_masterKopiList.isEmpty) {
      // ... (UI "Belum Ada Menu Kopi" Anda sudah baik) ...
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

    if (_displayedKopiList.isEmpty) {
      // Ini menangani kasus setelah filter tag atau search
      // ... (UI "Tidak Ada Kopi untuk Kategori/Search" Anda sudah baik) ...
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
                  'Tidak Ada Kopi untuk "$_activeTag"',
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

    // Jika ada data untuk ditampilkan
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
          final kopi = _displayedKopiList[index];
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
              _mulaiAnimasiTambahKeKeranjang(plusButtonKey, kopiUntukKeranjang);
              ScaffoldMessenger.of(context).showSnackBar(
                /* ... SnackBar Anda ... */
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
        }, childCount: _displayedKopiList.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KopiQuColors.background,
      body: RefreshIndicator(
        // RefreshIndicator sudah ada
        onRefresh: fetchKopi,
        color: KopiQuColors.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Sudah ada
          slivers: [
            SliverToBoxAdapter(
              // Header Section (padding atas)
              child: Container(
                // Anda bisa hilangkan gradient ini jika ingin background default Scaffold
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KopiQuColors.background,
                      KopiQuColors.background.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 16),
                ), // Jarak dari AppBar global
              ),
            ),
            SliverToBoxAdapter(
              // Banner Section
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  /* ... dekorasi banner container ... */
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Radius untuk container banner
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Radius untuk ClipRRect juga
                    child: BannerSlider(
                      bannerImages: bannerImages,
                      pageController: bannerController.pageController,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ), // Spasi lebih besar
            SliverToBoxAdapter(
              // Category Tags Section
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagList(activeTag: _activeTag, onTagSelected: _onTagSelected),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            _buildProductsGrid(), // Menggunakan method helper untuk grid produk
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
