// lib/screens/admin/admin_dashboard_content_page.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/screens/admin/admin_menu/admin_editMenu_screen.dart';
import 'package:kopiqu/screens/admin/admin_menu/admin_tambahMenu_screen.dart';
import 'package:kopiqu/widgets/admin/admin_menucard.dart';
import 'package:kopiqu/widgets/admin/dashboard_infocard.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Palet Warna
const Color kCafeDarkBrown = Color(0xFF4D2F15);
const Color kCafeMediumBrown = Color(0xFFB06C30);
const Color kCafeLightBrown = Color(0xFFE3B28C);
const Color kCafeVeryLightBeige = Color(0xFFF7E9DE);
const Color kCafeTextBlack = Color(0xFF1D1616);

class AdminDashboardContentPage extends StatefulWidget {
  const AdminDashboardContentPage({super.key});

  @override
  State<AdminDashboardContentPage> createState() =>
      _AdminDashboardContentPageState();
}

class _AdminDashboardContentPageState extends State<AdminDashboardContentPage> {
  String _displayName = 'Admin';
  String _totalMenu = 'memuat..';
  String _totalUsers = 'memuat..';

  List<Kopi> _kopiItems = [];
  bool _isLoadingMenu = true;
  String? _menuError;

  final Color _statistikCardColor = kCafeLightBrown;
  final Color _statistikCardTextColor = kCafeDarkBrown;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
    _fetchDashboardStats();
    _fetchKopiItems();
  }

  Future<void> _fetchAdminData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        _displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
      });
    }
  }

  Future<void> _fetchDashboardStats() async {
    if (!mounted) return;
    try {
      final dynamic response = await Supabase.instance.client.rpc(
        'get_total_user_count',
      );
      int userCount = 0;
      if (response != null && response is int) {
        userCount = response;
      } else {
        print(
          'Unexpected RPC response type for user count: ${response.runtimeType}, value: $response',
        );
      }
      if (mounted) {
        setState(() {
          _totalUsers = userCount.toString();
        });
      }
    } catch (error) {
      print('Error fetching total user count via RPC: $error');
      if (mounted) {
        setState(() {
          _totalUsers = 'N/A';
        });
      }
    }
  }

  Future<void> _fetchKopiItems() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMenu = true;
      _menuError = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('kopi')
          .select(
            'id, gambar, nama_kopi, komposisi, deskripsi, harga, created_at',
          )
          .order('created_at', ascending: false);

      if (mounted) {
        final List<dynamic> data = response as List<dynamic>;
        setState(() {
          _kopiItems =
              data
                  .map((item) => Kopi.fromMap(item as Map<String, dynamic>))
                  .toList();
          _isLoadingMenu = false;
          _totalMenu = _kopiItems.length.toString();
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _menuError = 'Gagal memuat data menu: ${error.toString()}';
          _isLoadingMenu = false;
          _totalMenu = 'N/A';
        });
        print('Error fetching kopi items: $error');
      }
    }
  }

  Future<void> _handleDeleteMenu(Kopi kopiItem) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIcons.warning(PhosphorIconsStyle.fill),
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 10),
              const Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus menu "${kopiItem.nama_kopi}"? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: kCafeMediumBrown),
                  ),
                  child: TextButton(
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: kCafeMediumBrown),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                TextButton(
                  child: Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await Supabase.instance.client
            .from('kopi')
            .delete()
            .eq('id', kopiItem.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menu "${kopiItem.nama_kopi}" berhasil dihapus.'),
              backgroundColor: kCafeDarkBrown,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchKopiItems();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus menu: $error'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _navigateToTambahMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahMenuPage()),
    );
    if (result == true && mounted) {
      _fetchKopiItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu baru ditambahkan. Daftar diperbarui.'),
          backgroundColor: kCafeDarkBrown,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildMenuListBody() {
    if (_isLoadingMenu && _kopiItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: kCafeMediumBrown),
      );
    }
    if (_menuError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.xCircle(PhosphorIconsStyle.regular),
                color: Colors.redAccent[700],
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                _menuError!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(
                  PhosphorIcons.arrowCounterClockwise(
                    PhosphorIconsStyle.regular,
                  ),
                  size: 18,
                ),
                label: const Text('Coba Lagi'),
                onPressed: _fetchKopiItems,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCafeMediumBrown,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_kopiItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.upload(PhosphorIconsStyle.regular),
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 10),
              const Text('Belum ada menu yang ditambahkan.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(
                  PhosphorIcons.plus(PhosphorIconsStyle.regular),
                  size: 18,
                ),
                label: const Text('Tambah Menu Pertama'),
                onPressed: _navigateToTambahMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCafeMediumBrown,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchKopiItems,
      color: kCafeMediumBrown,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 80.0,
          left: 16.0,
          right: 16.0,
        ),
        itemCount: _kopiItems.length,
        itemBuilder: (context, index) {
          final kopiItem = _kopiItems[index];
          return AdminMenuItemCard(
            kopiItem: kopiItem,
            onEdit: () async {
              final bool? result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMenuPage(kopi: kopiItem),
                ),
              );
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Menu "${kopiItem.nama_kopi}" telah diperbarui.',
                    ),
                    backgroundColor: kCafeDarkBrown,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _fetchKopiItems();
              }
            },
            onDelete: () => _handleDeleteMenu(kopiItem),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(
      context,
    ).textTheme.apply(bodyColor: kCafeTextBlack, displayColor: kCafeTextBlack);

    return Scaffold(
      backgroundColor: kCafeVeryLightBeige,
      appBar: AppBar(
        // --- MODIFIKASI DESAIN APPBAR DIMULAI DI SINI ---
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(
                  255,
                  216,
                  130,
                  65,
                ), // Warna merah aksen yang lebih pekat
                const Color(
                  0xFF804E23,
                ), // Warna merah aksen standar (lebih terang)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              // Anda juga bisa mencoba begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            // Border radius untuk flexibleSpace harus cocok dengan shape AppBar jika ingin seamless
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(10), // Sama dengan shape di AppBar
            ),
          ),
        ),
        backgroundColor: const Color(
          0xFF804E23,
        ), // Tetap berikan warna dasar jika flexibleSpace tidak digunakan atau sebagai fallback
        elevation:
            4.0, // Elevasi bisa sedikit dinaikkan untuk memperjelas bayangan dengan gradient
        centerTitle: true,
        title: Text(
          'Welcome, $_displayName!',
          style:
              textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 20,
                letterSpacing: 0.5,
              ) ??
              const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: Offset(0.5, 0.5),
                    blurRadius: 1.0,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
        ),
        foregroundColor:
            Colors
                .white, // Memastikan ikon default (spt back button) berwarna putih
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Sudut membulat di bawah
          ),
        ),
        // --- MODIFIKASI DESAIN APPBAR BERAKHIR DI SINI ---
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik Aplikasi',
                  style:
                      textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kCafeDarkBrown,
                      ) ??
                      const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kCafeDarkBrown,
                      ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: DashboardInfoCard(
                              title: 'Total Produk',
                              value: _totalMenu,
                              icon: PhosphorIcons.coffee(
                                PhosphorIconsStyle.regular,
                              ),
                              backgroundColor: _statistikCardColor,
                              iconColor: _statistikCardTextColor.withOpacity(
                                0.8,
                              ),
                              textColor: _statistikCardTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: DashboardInfoCard(
                              title: 'Total Pengguna',
                              value: _totalUsers,
                              icon: PhosphorIcons.users(
                                PhosphorIconsStyle.regular,
                              ),
                              backgroundColor: _statistikCardColor,
                              iconColor: _statistikCardTextColor.withOpacity(
                                0.8,
                              ),
                              textColor: _statistikCardTextColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Kelola Daftar Menu',
                        style:
                            textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: kCafeDarkBrown,
                            ) ??
                            const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kCafeDarkBrown,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          PhosphorIcons.plusCircle(PhosphorIconsStyle.fill),
                          size: 20,
                        ),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCafeMediumBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2.0,
                        ),
                        onPressed: _navigateToTambahMenu,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: kCafeLightBrown.withOpacity(0.5),
                  height: 20,
                  thickness: 1,
                ),
              ],
            ),
          ),
          Expanded(child: _buildMenuListBody()),
        ],
      ),
    );
  }
}
