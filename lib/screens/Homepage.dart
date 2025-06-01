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

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  // ... (semua variabel state dan method Anda yang sudah ada tetap sama) ...
  final bannerImages = ['assets/baner1.jpg', /* ... */ 'assets/baner5.jpg'];
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
    /* ... kode fetchKopi Anda tetap sama ... */
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
    /* ... kode _onTagSelected Anda tetap sama ... */
    if (!mounted) return;
    setState(() {
      _activeTag = tagName;
      _applyTagFilter();
    });
  }

  void _applyTagFilter() {
    /* ... kode _applyTagFilter Anda tetap sama ... */
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
    /* ... kode animasi Anda tetap sama ... */
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
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(
                        Icons.add_shopping_cart,
                        size: 15,
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
    Widget gridContent;
    if (_isLoadingKopi) {
      // 👇 2. GANTI CircularProgressIndicator DENGAN LOTTIE ANIMATION
      gridContent = SliverFillRemaining(
        // Tetap gunakan SliverFillRemaining
        child: Center(
          child: SizedBox(
            // Beri ukuran pada Lottie
            width: 500, // Sesuaikan ukuran Lottie Anda
            height: 500,
            child: Lottie.asset(
              'assets/lottie/Animation-hoomepage2.json', // PASTIKAN PATH INI BENAR
              onLoaded: (composition) {
                print("Animasi Lottie di Homepage (aset) berhasil dimuat.");
              },
              errorBuilder: (context, error, stackTrace) {
                print("Error memuat Lottie di Homepage dari aset: $error");
                // Fallback jika Lottie gagal, tampilkan CircularProgressIndicator standar
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8D6E63)),
                );
              },
            ),
          ),
        ),
      );
    } else if (_fetchKopiError != null) {
      gridContent = SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _fetchKopiError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchKopi,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_masterKopiList.isEmpty) {
      gridContent = const SliverFillRemaining(
        child: Center(child: Text('Tidak ada rekomendasi kopi saat ini.')),
      );
    } else if (_displayedKopiList.isEmpty &&
        _activeTag.isNotEmpty &&
        _activeTag != TagList.tagRekomendasi) {
      String message = 'Tidak ada kopi untuk kategori "$_activeTag".';
      gridContent = SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      );
    } else if (_displayedKopiList.isEmpty &&
        _activeTag == TagList.tagRekomendasi) {
      gridContent = const SliverFillRemaining(
        child: Center(
          child: Text('Tidak ada rekomendasi kopi yang bisa ditampilkan.'),
        ),
      );
    } else {
      gridContent = SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.65,
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
                _mulaiAnimasiTambahKeKeranjang(
                  plusButtonKey,
                  kopiUntukKeranjang,
                );
              },
            );
          }, childCount: _displayedKopiList.length),
        ),
      );
    }

    return Scaffold(
      appBar: null,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: BannerSlider(
              bannerImages: bannerImages,
              pageController: bannerController.pageController,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: TagList(
              activeTag: _activeTag,
              onTagSelected: _onTagSelected,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          gridContent, // Ini akan menampilkan Lottie saat loading, atau grid, atau pesan error/kosong
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
