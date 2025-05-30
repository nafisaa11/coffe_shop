// screens/Homepage.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Banner_Controller.dart'; // Pastikan ini mengarah ke Banner_Controller.dart yang baru
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/banner_slider.dart';
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart';
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // ✅ Inisialisasi BannerController tanpa parameter
  final BannerController bannerController = BannerController();

  final supabase = Supabase.instance.client;
  List<Kopi> _masterKopiList = [];
  List<Kopi> _filteredKopiList = [];
  bool _isLoadingKopi = true;
  String? _fetchKopiError;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Tidak perlu lagi `bannerController = BannerController(actualBannerImagesLength: bannerImages.length);`
    // karena sudah diinisialisasi di atas.

    fetchKopi();

    // ✅ Panggil startAutoScroll dengan list gambar dan callback setState
    bannerController.startAutoScroll(bannerImages, () {
      if (mounted) {
        // Callback ini akan dipanggil oleh Timer di BannerController
        // setelah animateToPage. Ini bisa digunakan untuk memicu rebuild
        // jika ada UI yang bergantung pada currentPage dari controller,
        // misalnya indikator titik halaman (dots).
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    _searchController.dispose();
    _animationController?.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  // ... (method fetchKopi, _filterKopiList, _mulaiAnimasiTambahKeKeranjang tetap sama) ...
  Future<void> fetchKopi() async {
    setState(() {
      _isLoadingKopi = true;
      _fetchKopiError = null;
    });
    try {
      final response = await supabase.from('kopi').select();
      if (mounted) {
        setState(() {
          _masterKopiList = Kopi.listFromJson(response as List<dynamic>);
          _filteredKopiList = List.from(_masterKopiList);
          _isLoadingKopi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingKopi = false;
          _fetchKopiError = "Gagal memuat rekomendasi: ${e.toString()}";
        });
        print("Error fetching kopi on homepage: $e");
      }
    }
  }

  void _filterKopiList(String query) {
    final List<Kopi> filteredList = [];
    if (query.isEmpty) {
      filteredList.addAll(_masterKopiList);
    } else {
      filteredList.addAll(
        _masterKopiList.where(
          (kopi) => kopi.nama_kopi.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
    setState(() {
      _searchQuery = query;
      _filteredKopiList = filteredList;
    });
  }

  void _mulaiAnimasiTambahKeKeranjang(
    GlobalKey tombolPlusKeyDariCard,
    Kopi kopiYangDitambahkan,
  ) {
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
    // ... (logika gridContent Anda tetap sama) ...
    Widget gridContent;
    if (_isLoadingKopi) {
      gridContent = const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
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
    } else if (_filteredKopiList.isEmpty && _searchQuery.isNotEmpty) {
      gridContent = SliverFillRemaining(
        child: Center(
          child: Text('Kopi dengan nama "$_searchQuery" tidak ditemukan.'),
        ),
      );
    } else if (_masterKopiList.isEmpty) {
      gridContent = const SliverFillRemaining(
        child: Center(child: Text('Tidak ada rekomendasi kopi saat ini.')),
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
            final kopi = _filteredKopiList[index];
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
          }, childCount: _filteredKopiList.length),
        ),
      );
    }

    return Scaffold(
      appBar: null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: SearchWidget(
                controller: _searchController,
                onChanged: _filterKopiList,
                hintText: 'Cari kopi favoritmu...',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: BannerSlider(
              bannerImages: bannerImages,
              pageController: bannerController.pageController,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          const SliverToBoxAdapter(child: TagList()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          gridContent,
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
