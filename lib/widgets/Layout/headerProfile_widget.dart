// widgets/Layout/headerProfile_widget.dart
import 'dart:async'; // 👈 1. IMPORT dart:async untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  StreamSubscription<AuthState>?
  _authSubscription; // 👈 2. StreamSubscription untuk auth events

  @override
  void initState() {
    super.initState();
    // 👇 3. Dengarkan perubahan pada AuthState
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      // Jika ada event userUpdated (misalnya setelah metadata diubah)
      if (event == AuthChangeEvent.userUpdated) {
        if (mounted) {
          // Selalu cek mounted dalam listener async
          print(
            '[ProfileHeader] AuthStateChange: userUpdated event diterima, me-refresh UI.',
          );
          setState(() {
            // Memanggil setState akan memicu build ulang,
            // dan build method akan mengambil currentUser terbaru.
          });
        }
      }
      // Anda juga bisa menangani event lain jika perlu, misalnya signedIn, signedOut
    });
    // Tidak perlu memuat data spesifik di sini karena build method akan melakukannya.
  }

  @override
  void dispose() {
    _authSubscription
        ?.cancel(); // 👈 4. Batalkan subscription saat widget di-dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 👇 5. Ambil data pengguna terbaru SETIAP KALI widget di-build ulang
    final user = Supabase.instance.client.auth.currentUser;
    final String displayName = user?.userMetadata?['display_name'] ?? 'Pengguna';
    final String email = user?.email ?? 'Tidak ada email';
    final String? photoUrl = user?.userMetadata?['photo_url'] as String?;

    ImageProvider profileImageProvider;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      profileImageProvider = NetworkImage(photoUrl);
    } else {
      profileImageProvider = const AssetImage(
        'assets/fotoprofile.jpg',
      ); // Fallback ke aset default
    }

    print(
      '[ProfileHeader] build() dipanggil. Photo URL: $photoUrl',
    ); // Untuk debugging

    return Container(
      width: double.infinity,
      color: const Color(0xFFD07C3D),
      padding: const EdgeInsets.only(top: 70, bottom: 25, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo KopiQu (Opsional, jika tidak ada di AppBar MainScreen)
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Image.asset('assets/kopiqu.png', height: 30),
          // ),
          // const SizedBox(height: 15),
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white.withAlpha(
              (0.5 * 255).round(),
            ), // Menggunakan withAlpha
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              key: ValueKey(
                photoUrl ??
                    'assets/foto.jpg_${DateTime.now().millisecondsSinceEpoch}',
              ), // ValueKey diperbarui
              backgroundImage: profileImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                print(
                  "Error loading profile image from network: $exception. Falling back to asset.",
                );
                // Tidak perlu setState di sini jika logika displayImageProvider sudah benar
              },
              child:
                  
                       null,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha((0.85 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
}
