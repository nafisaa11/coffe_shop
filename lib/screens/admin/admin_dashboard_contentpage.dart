// lib/screens/admin/admin_dashboard_content_page.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/screens/admin/admin_menu/admin_editMenu_screen.dart';
import 'package:kopiqu/screens/admin/admin_menu/admin_tambahMenu_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/widgets/admin/dashboard_infocard.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/admin/admin_menucard.dart'; // Pastikan path ini benar

// Palet Warna (jika belum diimport dari file terpisah)
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
  String _totalMenu = 'memuat';
  String _totalUsers = 'memuat';

  List<Kopi> _kopiItems = [];
  bool _isLoadingMenu = true;
  String? _menuError;

  // Warna untuk statistik card menggunakan palet baru
  final Color _statistikCardColor = kCafeLightBrown;
  final Color _statistikCardTextColor =
      kCafeDarkBrown; // Teks lebih gelap untuk kontras

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
    // ... (logika fetch stats Anda tidak berubah signifikan, kecuali mungkin pesan error) ...
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
          _totalUsers = 'N/A'; // Tampilan error lebih baik
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
          .select('id, gambar, nama_kopi, komposisi, deskripsi, harga, created_at')
          .order(
            'created_at',
            ascending: false,
          ); // Contoh: Urutkan berdasarkan terbaru

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
          _totalMenu = 'N/A'; // Tampilan error lebih baik
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
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus menu "${kopiItem.nama_kopi}"? Tindakan ini tidak dapat diurungkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: kCafeMediumBrown),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // setState(() => _isLoadingMenu = true); // Optional: show loading indicator during delete
      try {
        await Supabase.instance.client
            .from('kopi')
            .delete()
            .eq('id', kopiItem.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Menu "${kopiItem.nama_kopi}" berhasil dihapus.'),
              backgroundColor: kCafeDarkBrown, // Warna tema
              behavior: SnackBarBehavior.floating,
            ),
          );
          _fetchKopiItems(); // Refresh list
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
      } finally {
        // if (mounted) setState(() => _isLoadingMenu = false);
      }
    }
  }

  void _navigateToTambahMenu() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahMenuPage()),
    );
    if (result == true && mounted) {
      // Jika TambahMenuPage pop dengan true
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
      // Hanya tampilkan loading utama jika list kosong
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
              Icon(Icons.error_outline, color: Colors.redAccent[700], size: 50),
              const SizedBox(height: 10),
              Text(
                _menuError!,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
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
              Icon(Icons.no_food_outlined, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 10),
              const Text('Belum ada menu yang ditambahkan.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
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
      color: kCafeMediumBrown, // Warna indikator refresh
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 80.0, // Padding bawah untuk FAB jika ada
          left: 16.0,
          right: 16.0,
        ),
        itemCount: _kopiItems.length,
        itemBuilder: (context, index) {
          final kopiItem = _kopiItems[index];
          return AdminMenuItemCard(
            // Ini sudah menggunakan card yang baru
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
    // Dapatkan text theme untuk konsistensi
    TextTheme textTheme = Theme.of(
      context,
    ).textTheme.apply(bodyColor: kCafeTextBlack, displayColor: kCafeTextBlack);

    return Scaffold(
      // Tambahkan Scaffold jika ini adalah konten utama sebuah screen
      backgroundColor: kCafeVeryLightBeige, // Latar belakang utama halaman
      appBar: AppBar(
        title: Text(
          'Welcome, $_displayName!',
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: kCafeDarkBrown, // AppBar dengan warna tema
        foregroundColor: Colors.white,
        elevation: 2.0,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Updated section for statistics grid in AdminDashboardContentPage
          // Replace the existing GridView.count with this responsive version:

          // In the build method, replace the statistics section:
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

                // Responsive grid using LayoutBuilder
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate card width based on available space
                    // double cardWidth =
                    //     (constraints.maxWidth - 16) /
                    //     2; // 16 for spacing between cards
                    // double cardHeight =
                    //     cardWidth * 0.6; // Maintain aspect ratio

                    // // Ensure minimum dimensions
                    // cardHeight = cardHeight.clamp(40.0, 120.0);

                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: DashboardInfoCard(
                              title: 'Total Produk',
                              value: _totalMenu,
                              icon: Icons.coffee_outlined,
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
                              icon: Icons.group_outlined,
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

                // Header row with responsive button
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
                    const SizedBox(width: 8), // Add spacing
                    Flexible(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kCafeMediumBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, // Reduced padding
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13, // Slightly smaller font
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
