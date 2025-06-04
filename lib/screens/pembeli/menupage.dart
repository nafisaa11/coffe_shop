// screens/menupage.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Untuk Random jika Anda menggunakannya di _applyFilters (saat ini tidak di MenuPage)
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Layout/sliver_search_header_delegate.dart'; // 👈 IMPORT DELEGATE
import 'package:kopiqu/widgets/Homepage/tag_list.dart'; // Anda menyebutkan TagList dihilangkan di MenuPage, jadi ini bisa dihapus jika tidak dipakai
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:kopiqu/controllers/keranjang/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  List<Kopi> _masterKopiList = [];
  List<Kopi> _filteredKopiList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fetchKopiData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController?.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _fetchKopiData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final supabase = Supabase.instance.client;
      // Ambil semua kopi, mungkin diurutkan berdasarkan nama atau ID
      final response = await supabase
          .from('kopi')
          .select()
          .order('nama_kopi', ascending: true);
      if (mounted) {
        _masterKopiList = Kopi.listFromJson(response as List<dynamic>);
        _filteredKopiList = List.from(_masterKopiList);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data kopi: ${e.toString()}';
        });
        print('Error fetching kopi data in MenuPage: $e');
      }
    }
  }

  void _filterKopiList(String query) {
    if (!mounted) return;
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
        "[MenuPage] Gagal memulai animasi: key atau posisi keranjang tidak valid.",
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
    // Tentukan widget untuk bagian sliver grid berdasarkan state
    Widget kopiGridSliver;
    if (_isLoading) {
      kopiGridSliver = const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_errorMessage != null) {
      kopiGridSliver = SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  onPressed: _fetchKopiData,
                ),
              ],
            ),
          ),
        ),
      );
    } else if (_masterKopiList.isEmpty) {
      kopiGridSliver = const SliverFillRemaining(
        child: Center(
          child: Text(
            'Tidak ada produk kopi yang tersedia saat ini.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    } else if (_filteredKopiList.isEmpty && _searchQuery.isNotEmpty) {
  kopiGridSliver = SliverFillRemaining(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon pencarian tidak ditemukan
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            
            // Judul
            const Text(
              'Kopi Tidak Ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723), // KopiQuColors.textPrimary
              ),
            ),
            const SizedBox(height: 8),
            
            // Pesan
            Text(
              'Kopi dengan nama "$_searchQuery" tidak ditemukan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8D6E63), // KopiQuColors.textMuted
              ),
            ),
            const SizedBox(height: 16),
          
          ],
        ),
      ),
    ),
  );
    } else {
      kopiGridSliver = SliverPadding(
        padding: const EdgeInsets.all(16.0), // Padding untuk keseluruhan grid
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                0.65, // Sesuaikan childAspectRatio dengan desain CoffeeCard
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final kopi = _filteredKopiList[index];
            return CoffeeCard(
              kopi: kopi,
              onAddToCartPressed: (
                GlobalKey plusButtonKey,
                Kopi kopiUntukKeranjang,
              ) {
                String ukuranPilihan =
                    "Sedang"; // Tambahkan logika pemilihan ukuran
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
      // AppBar akan dihandle oleh MainScreen
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true, // Membuat header "menempel" di atas saat scroll
            delegate: SliverSearchHeaderDelegate(
              searchWidget: SearchWidget(
                controller: _searchController,
                onChanged: _filterKopiList,
                hintText: 'Cari semua menu kopi...',
              ),
              // Warna latar belakang untuk area search bar.
              // Gunakan Theme.of(context).scaffoldBackgroundColor agar menyatu,
              // atau Theme.of(context).appBarTheme.backgroundColor jika ingin sama dengan AppBar
              backgroundColor: Colors.white,
            ),
          ),
          // Jika Anda ingin TagList di MenuPage, uncomment baris berikut
          // const SliverToBoxAdapter(child: SizedBox(height: 10)), // Spasi sebelum TagList
          // SliverToBoxAdapter(
          //   child: TagList(
          //     activeTag: _activeTag, // Anda perlu state _activeTag jika menggunakan TagList di sini
          //     onTagSelected: _onTagSelected, // Anda perlu method _onTagSelected jika menggunakan TagList
          //   ),
          // ),
          // const SliverToBoxAdapter(child: SizedBox(height: 16)), // Spasi setelah TagList
          kopiGridSliver, // Masukkan sliver yang berisi grid kopi atau pesan state
        ],
      ),
    );
  }
}
