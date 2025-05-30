// screens/menupage.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
// import 'package:kopiqu/widgets/Layout/header_widget.dart'; // Tidak digunakan lagi jika AppBar global
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart';
import 'package:kopiqu/widgets/Homepage/search_widget.dart'; // Pastikan path ini benar
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  // State untuk daftar kopi
  List<Kopi> _masterKopiList = []; // Daftar semua kopi dari database
  List<Kopi> _filteredKopiList =
      []; // Daftar kopi yang akan ditampilkan (setelah filter)
  bool _isLoading = true;
  String? _errorMessage;

  // State untuk Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Variabel untuk Animasi Tambah ke Keranjang
  OverlayEntry? _overlayEntry;
  AnimationController? _animationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  // String? _animatingKopiImageUrl; // Opsional, jika ingin gambar produk terbang

  @override
  void initState() {
    super.initState();
    _fetchKopiData();
    // Tidak perlu listener di _searchController jika SearchWidget memanggil onChanged
    // _searchController.addListener(() {
    //   _filterKopiList(_searchController.text);
    // });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose search controller
    _animationController?.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _fetchKopiData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('kopi').select();
      if (mounted) {
        setState(() {
          _masterKopiList = Kopi.listFromJson(response as List<dynamic>);
          _filteredKopiList = List.from(
            _masterKopiList,
          ); // Inisialisasi filtered list
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

  // Method untuk memfilter daftar kopi berdasarkan query
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
    // ... (kode _mulaiAnimasiTambahKeKeranjang Anda tetap sama persis seperti di Homepage.dart) ...
    final cartUiService = Provider.of<CartUIService>(context, listen: false);
    cartUiService.updateCartIconPosition();

    final Offset? posisiAkhirKeranjang = cartUiService.cartIconPosition;

    if (tombolPlusKeyDariCard.currentContext == null ||
        posisiAkhirKeranjang == null) {
      print(
        "[MenuPage] Gagal memulai animasi: key atau posisi keranjang tidak valid.",
      );
      Provider.of<KeranjangController>(
        context,
        listen: false,
      ).tambah(kopiYangDitambahkan, "Sedang");
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
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                onPressed: _fetchKopiData,
              ),
            ],
          ),
        ),
      );
    } else if (_filteredKopiList.isEmpty && _searchQuery.isNotEmpty) {
      // Kondisi jika hasil filter kosong
      bodyContent = Center(
        child: Text('Kopi dengan nama "$_searchQuery" tidak ditemukan.'),
      );
    } else if (_masterKopiList.isEmpty) {
      // Kondisi jika master list memang kosong
      bodyContent = const Center(
        child: Text('Tidak ada produk kopi yang tersedia saat ini.'),
      );
    } else {
      bodyContent = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              // Beri padding atas jika search mepet dengan AppBar dari MainScreen
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 0,
              ),
              // 👇 Integrasikan SearchWidget
              child: SearchWidget(
                controller: _searchController,
                onChanged:
                    _filterKopiList, // Panggil _filterKopiList saat teks berubah
                hintText: 'Cari semua menu kopi...', // Sesuaikan hint text
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: TagList()), // Widget TagList Anda
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    0.65, // Sesuaikan dengan desain CoffeeCard Anda
              ),
              // 👇 Gunakan _filteredKopiList untuk menampilkan data
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final kopi = _filteredKopiList[index];
                  return CoffeeCard(
                    kopi: kopi,
                    onAddToCartPressed: (
                      GlobalKey plusButtonKey,
                      Kopi kopiUntukKeranjang,
                    ) {
                      String ukuranPilihan =
                          "Sedang"; // Ganti dengan logika pemilihan ukuran
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
                },
                childCount: _filteredKopiList.length,
              ), // Gunakan panjang _filteredKopiList
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      );
    }

    return Scaffold(
      // AppBar sudah dihandle oleh MainScreen, jadi tidak perlu di sini.
      body: bodyContent, // Tidak perlu lagi Stack untuk header lokal
    );
  }
}
