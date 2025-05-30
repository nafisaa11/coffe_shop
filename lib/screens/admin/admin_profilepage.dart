import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Impor AuthService untuk logout

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Anda bisa mengambil data user dari Supabase di sini jika diperlukan
    final user = Supabase.instance.client.auth.currentUser;
    final String displayName = user?.userMetadata?['display_name'] ?? 'Admin';
    final String email = user?.email ?? 'Tidak ada email';

    return Scaffold(
      // Tambahkan Scaffold agar bisa ada AppBar jika dipanggil langsung
      // appBar: AppBar(title: Text("Profil Admin")), // Opsional jika halaman ini bisa diakses sendiri
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                // backgroundImage: NetworkImage('URL_FOTO_PROFIL_ADMIN_JIKA_ADA'),
                child: Icon(Icons.admin_panel_settings, size: 50),
              ),
              const SizedBox(height: 20),
              Text('Nama: $displayName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Email: $email', style: TextStyle(fontSize: 16)),
              const Text(
                'Halaman Profil Admin',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Fitur profil admin akan dikembangkan di sini.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  await AuthService().logout(context);
                  // Navigasi ke halaman login sudah ditangani di dalam fungsi logout AuthService
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
