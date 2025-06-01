// screens/Homepage.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kopiqu/controllers/Banner_Controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/banner_slider.dart';
import 'package:kopiqu/widgets/Homepage/gridHomepage_widget.dart';
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Warna tema yang konsisten (sama dengan yang di CoffeeCard)
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

  // Animation variables
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
    final cartUiService = Provider.of<CartUIService>(context, listen: false);
    cartUiService.updateCartIconPosition();
    final Offset? posisiAkhirKeranjang = cartUiService.cartIconPosition;

    if (tombolPlusKeyDariCard.currentContext == null || posisiAkhirKeranjang == null) {
      print("[Homepage] Gagal memulai animasi: key atau posisi keranjang tidak valid.");
      String ukuranPilihan = "Sedang";
      Provider.of<KeranjangController>(context, listen: false)
          .tambah(kopiYangDitambahkan, ukuranPilihan);
      return;
    }

    final RenderBox tombolRenderBox =
        tombolPlusKeyDariCard.currentContext!.findRenderObject() as RenderBox;
    final Offset posisiAwalTombol = tombolRenderBox.localToGlobal(Offset.zero);
    final Offset posisiAwalAnimasi = posisiAwalTombol +
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
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOutCubic,
    ));
    
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
                (!_animationController!.isAnimating &&
                    _animationController!.status != AnimationStatus.forward)) {
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
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: KopiQuColors.success,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KopiQuColors.background,
      body: RefreshIndicator(
        onRefresh: fetchKopi,
        color: KopiQuColors.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
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
                child: Padding(padding: EdgeInsets.only(top: 20)),
              ),
            ),

            // Banner Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BannerSlider(
                      bannerImages: bannerImages,
                      pageController: bannerController.pageController,
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Category Tags Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagList(
                    activeTag: _activeTag,
                    onTagSelected: _onTagSelected,
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Products Grid - Menggunakan widget terpisah
            GridHomepageWidget(
              isLoadingKopi: _isLoadingKopi,
              fetchKopiError: _fetchKopiError,
              masterKopiList: _masterKopiList,
              displayedKopiList: _displayedKopiList,
              activeTag: _activeTag,
              onRefresh: fetchKopi,
              onAddToCartPressed: _mulaiAnimasiTambahKeKeranjang,
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              children: [
            
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nikmati kopi premium dengan layanan terbaik',
            style: TextStyle(
              fontSize: 16,
              color: KopiQuColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}