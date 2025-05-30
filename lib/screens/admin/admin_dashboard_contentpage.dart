import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/widgets/admin/dashboard_infocard.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/admin/admin_menucard.dart'; // Pastikan ini AdminMenuItemCard atau nama yang benar

class AdminDashboardContentPage extends StatefulWidget {
  const AdminDashboardContentPage({super.key});

  @override
  State<AdminDashboardContentPage> createState() =>
      _AdminDashboardContentPageState();
}

class _AdminDashboardContentPageState extends State<AdminDashboardContentPage> {
  String _displayName = 'Admin';
  String _totalMenu = 'memuat...';
  String _totalUsers = 'memuat...';

  List<Kopi> _kopiItems = [];
  bool _isLoadingMenu = true;
  String? _menuError;

  final Color selamatDatangColor = const Color(0xFFD3864A);
  final Color statistikCardColor = const Color(0xFFE3B28C);
  final Color statistikCardTextColor = const Color(0xFF4E342E);

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
          _totalUsers = 'Gagal';
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
          .select('id, gambar, nama_kopi, komposisi, deskripsi, harga');

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
          _totalMenu = 'Gagal';
        });
        print('Error fetching kopi items: $error');
      }
    }
  }

  void _handleEditMenu(Kopi kopiItem) {
    print('Edit menu: ${kopiItem.nama_kopi}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur edit untuk ${kopiItem.nama_kopi} belum diimplementasikan.',
        ),
      ),
    );
  }

  Future<void> _handleDeleteMenu(Kopi kopiItem) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus menu "${kopiItem.nama_kopi}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red[700])),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      print('Hapus menu: ${kopiItem.nama_kopi}');
      try {
        // TODO: Implementasi penghapusan dari Supabase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Menu "${kopiItem.nama_kopi}" (belum) dihapus. Implementasi backend diperlukan.',
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus menu: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMenuListBody() {
    // Ganti nama agar lebih jelas ini adalah "body" dari list
    if (_isLoadingMenu) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_menuError != null) {
      return Center(
        child: Text(_menuError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_kopiItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Belum ada menu yang ditambahkan.'),
        ),
      );
    }
    // Jika tidak ada error, loading, atau item kosong, tampilkan daftar menu
    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 16.0,
        left: 16.0,
        right: 16.0,
      ), // Padding untuk list
      itemCount: _kopiItems.length,
      itemBuilder: (context, index) {
        final kopiItem = _kopiItems[index];
        return AdminMenuItemCard(
          kopiItem: kopiItem,
          onEdit: () => _handleEditMenu(kopiItem),
          onDelete: () => _handleDeleteMenu(kopiItem),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // 1. Parent utama adalah Column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Atas (Welcome, Statistik) - TIDAK IKUT SCROLL
        Padding(
          padding: const EdgeInsets.all(16.0), // Padding untuk grup atas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Container
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: selamatDatangColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            _displayName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Statistik Aplikasi
              Text(
                'Statistik Aplikasi',
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ) ??
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true, // Penting karena di dalam Column
                physics:
                    const NeverScrollableScrollPhysics(), // Penting karena di dalam Column
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  DashboardInfoCard(
                    title: 'Total Menu Saat Ini',
                    value: _totalMenu,
                    icon: Icons.restaurant_menu,
                    backgroundColor: statistikCardColor,
                    iconColor: statistikCardTextColor.withOpacity(0.7),
                    textColor: statistikCardTextColor,
                  ),
                  DashboardInfoCard(
                    title: 'Total Pengguna Terdaftar',
                    value: _totalUsers,
                    icon: Icons.people_alt,
                    backgroundColor: statistikCardColor,
                    iconColor: statistikCardTextColor.withOpacity(0.7),
                    textColor: statistikCardTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Row untuk "Daftar Menu" dan Tombol "Tambah Menu" - TIDAK IKUT SCROLL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Menu',
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Tambah Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fitur Tambah Menu belum diimplementasikan.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2), // Jarak sebelum list menu
            ],
          ),
        ),

        // Bagian List Menu yang Bisa Di-scroll
        Expanded(
          // 2. Expanded agar ListView mengambil sisa ruang
          child:
              _buildMenuListBody(), // Gunakan fungsi yang mengembalikan ListView
        ),
      ],
    );
  }
}
