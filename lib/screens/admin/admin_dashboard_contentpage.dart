import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/widgets/admin/dashboard_infocard.dart'; // Impor komponen kartu

class AdminDashboardContentPage extends StatefulWidget {
  const AdminDashboardContentPage({super.key});

  @override
  State<AdminDashboardContentPage> createState() => _AdminDashboardContentPageState();
}

class _AdminDashboardContentPageState extends State<AdminDashboardContentPage> {
  String _displayName = 'Admin';
  String _totalMenu = '...'; // Placeholder
  String _totalUsers = '...'; // Placeholder

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
    _fetchDashboardStats(); // Panggil fungsi untuk mengambil data statistik
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
    // Simulasi pengambilan data
    await Future.delayed(const Duration(seconds: 1)); 
    
    // Contoh: Ambil jumlah menu
    // final menuResponse = await Supabase.instance.client.from('menu').select('id', const FetchOptions(count: CountOption.exact));
    // final int menuCount = menuResponse.count ?? 0;

    // Contoh: Ambil jumlah user (pembeli)
    // Anda mungkin perlu fungsi RPC atau query yang lebih spesifik jika ingin memfilter role 'pembeli'
    // final usersResponse = await Supabase.instance.client.from('users').select('id', const FetchOptions(count: CountOption.exact)); // Ini akan mengambil semua user di tabel 'users' jika ada
    // final int userCount = usersResponse.count ?? 0;
    
    if (mounted) {
      setState(() {
        _totalMenu = "15"; // Ganti dengan menuCount.toString();
        _totalUsers = "120"; // Ganti dengan userCount.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Welcome
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColorDark ?? Colors.brown.shade700,
                  Theme.of(context).primaryColor ?? Colors.brown,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 15),
                Column(
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Judul Statistik
          Text(
            'Statistik Aplikasi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Grid untuk Info Card
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Agar tidak bisa di-scroll di dalam GridView
            crossAxisCount: 2, // 2 kartu per baris
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5, // Sesuaikan rasio aspek kartu
            children: [
              DashboardInfoCard(
                title: 'Total Menu Saat Ini',
                value: _totalMenu,
                icon: Icons.restaurant_menu,
                iconColor: Colors.white.withOpacity(0.8),
              ),
              DashboardInfoCard(
                title: 'Total Pengguna Aktif', // Atau "Total Pembeli Terdaftar"
                value: _totalUsers,
                icon: Icons.people_alt,
                iconColor: Colors.white.withOpacity(0.8),
              ),
              // Anda bisa menambahkan kartu lain di sini
              // DashboardInfoCard(title: 'Total Pesanan Hari Ini', value: '25', icon: Icons.shopping_cart),
              // DashboardInfoCard(title: 'Pendapatan Hari Ini', value: 'Rp 1.2M', icon: Icons.attach_money),
            ],
          ),

          const SizedBox(height: 24),
          // TODO: Tambahkan bagian lain seperti CRUD menu di sini nanti
          // Center(child: ElevatedButton(onPressed: () { /* Navigasi ke CRUD Menu */ }, child: Text('Kelola Menu'))),
        ],
      ),
    );
  }
}