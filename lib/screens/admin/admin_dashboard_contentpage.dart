import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/widgets/admin/dashboard_infocard.dart';
import 'package:kopiqu/models/kopi.dart'; // <-- 1. IMPORT MODEL Kopi ANDA (pastikan path benar)
import 'package:kopiqu/widgets/admin/admin_menucard.dart';

class AdminDashboardContentPage extends StatefulWidget {
  const AdminDashboardContentPage({super.key});

  @override
  State<AdminDashboardContentPage> createState() =>
      _AdminDashboardContentPageState();
}

class _AdminDashboardContentPageState extends State<AdminDashboardContentPage> {
  String _displayName = 'Admin';
  String _totalMenu = '...';
  String _totalUsers = '...';

  List<Kopi> _kopiItems = []; // <-- 2. UBAH TIPE LIST menjadi List<Kopi>
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
    _fetchKopiItems(); // <-- 3. GANTI NAMA FUNGSI FETCH
  }

  Future<void> _fetchAdminData() async {
    // ... (tetap sama) ...
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        _displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
      });
    }
  }

  Future<void> _fetchDashboardStats() async {
    // ... (tetap sama, tapi Anda mungkin ingin mengambil _totalMenu dari _kopiItems.length setelah fetch) ...
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _totalMenu =
            _kopiItems.isNotEmpty
                ? _kopiItems.length.toString()
                : "0"; // Update dari data menu
        _totalUsers = "120"; // Ganti dengan data user asli
      });
    }
  }

  // 4. FUNGSI FETCH DIUBAH UNTUK MODEL Kopi
  Future<void> _fetchKopiItems() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMenu = true;
      _menuError = null;
    });
    try {
      // Sesuaikan 'kopi_table' dengan nama tabel menu Anda di Supabase
      // Sesuaikan juga nama kolom yang dipilih agar cocok dengan field di model Kopi
      final response = await Supabase.instance.client
          .from('kopi') // GANTI 'kopi' dengan nama tabel menu Anda
          .select(
            'id, gambar, nama_kopi, komposisi, deskripsi, harga',
          ); // Pilih semua kolom yang ada di model Kopi

      if (mounted) {
        final List<dynamic> data = response as List<dynamic>;
        // Gunakan Kopi.fromMap atau Kopi.listFromJson jika ada
        setState(() {
          _kopiItems =
              data
                  .map((item) => Kopi.fromMap(item as Map<String, dynamic>))
                  .toList();
          // atau jika Anda punya Kopi.listFromJson(data):
          // _kopiItems = Kopi.listFromJson(data);
          _isLoadingMenu = false;
          _totalMenu =
              _kopiItems.length
                  .toString(); // Update total menu berdasarkan data yang diambil
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _menuError = 'Gagal memuat data menu: ${error.toString()}';
          _isLoadingMenu = false;
        });
        print('Error fetching kopi items: $error');
      }
    }
  }

  void _handleEditMenu(Kopi kopiItem) {
    // <-- UBAH TIPE PARAMETER
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
    // <-- UBAH TIPE PARAMETER
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
        // TODO: Implementasi penghapusan dari Supabase menggunakan kopiItem.id
        // await Supabase.instance.client.from('kopi').delete().match({'id': kopiItem.id});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Menu "${kopiItem.nama_kopi}" (belum) dihapus. Implementasi backend diperlukan.',
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        // _fetchKopiItems(); // Panggil ini setelah implementasi delete di backend
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

  Widget _buildMenuList() {
    if (_isLoadingMenu) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_menuError != null) {
      return Center(
        child: Text(_menuError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_kopiItems.isEmpty) {
      // <-- GUNAKAN _kopiItems
      return const Center(child: Text('Belum ada menu yang ditambahkan.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kopiItems.length, // <-- GUNAKAN _kopiItems
      itemBuilder: (context, index) {
        final kopiItem = _kopiItems[index]; // <-- GUNAKAN _kopiItems
        return AdminMenuItemCard(
          kopiItem: kopiItem, // <-- KIRIM objek Kopi
          onEdit: () => _handleEditMenu(kopiItem),
          onDelete: () => _handleDeleteMenu(kopiItem),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Bagian atas build method tetap sama: SingleChildScrollView, Column, Welcome Container, Statistik) ...
    final Color primaryDark = Theme.of(context).primaryColorDark;
    final Color primary = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'Statistik Aplikasi',
            style:
                Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              DashboardInfoCard(
                title: 'Total Menu Saat Ini',
                value:
                    _totalMenu, // Ini akan diupdate oleh _fetchKopiItems atau _fetchDashboardStats
                icon: Icons.restaurant_menu,
                backgroundColor: statistikCardColor,
                iconColor: statistikCardTextColor.withOpacity(0.7),
                textColor: statistikCardTextColor,
              ),
              DashboardInfoCard(
                title: 'Total Pengguna Aktif',
                value: _totalUsers,
                icon: Icons.people_alt,
                backgroundColor: statistikCardColor,
                iconColor: statistikCardTextColor.withOpacity(0.7),
                textColor: statistikCardTextColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Menu',
                style:
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ) ??
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Tambah Menu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.brown, // Warna latar belakang tombol
                  foregroundColor:Colors.white, // <-- TAMBAHKAN INI untuk warna teks dan ikon
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ), // Sedikit bold untuk teks
                  shape: RoundedRectangleBorder(
                    // Opsional: membuat sudut tombol sedikit melengkung
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
          const SizedBox(height: 16),
          _buildMenuList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
