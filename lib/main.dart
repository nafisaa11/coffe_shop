import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/KeranjangController.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/keranjangScreen.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/struk.dart';
import 'package:kopiqu/screens/transaksiScreen.dart';
import 'package:provider/provider.dart';
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/admin/admindashboard.dart';
import 'package:kopiqu/screens/resetpasswordpage.dart';

Future<void> main() async {
  // Wajib: inisialisasi Flutter sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://xuivlesfrjbjtaaavtma.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1aXZsZXNmcmpianRhYWF2dG1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyODc3OTgsImV4cCI6MjA2Mjg2Mzc5OH0.g33UOprpbbVXqpXtP3tY2nedOeCZklO003S4aZrUQsE',
  );

  // Jalankan aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => KeranjangController())],
      child: MyApp(),
    ),
  );
}

// 2. Ubah MyApp menjadi StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 3. Tambahkan GlobalKey untuk Navigator
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // 4. Panggil setup listener di initState
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print("Auth Event di MyApp: $event"); // Untuk debugging

      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        // Pengguna datang dari link reset password
        final userEmail = session.user?.email;
        print(
          "Password Recovery event diterima untuk email: $userEmail",
        ); // Debugging
        if (userEmail != null) {
          // Gunakan GlobalKey untuk navigasi karena listener ini berada di atas MaterialApp context biasa
          // Pastikan navigatorKey sudah di-assign ke MaterialApp
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(email: userEmail),
            ),
            (route) =>
                false, // Hapus semua rute sebelumnya agar pengguna tidak bisa kembali
          );
        } else {
          print(
            "Email pengguna tidak ditemukan di session setelah password recovery.",
          );
        }
      } else if (event == AuthChangeEvent.signedIn) {
        print("User signed in: ${session?.user?.email}");
        // Anda bisa menambahkan logika navigasi setelah login di sini jika diperlukan,
        // tapi biasanya ini sudah ditangani di halaman login itu sendiri.
      } else if (event == AuthChangeEvent.signedOut) {
        print("User signed out");
        // Jika ingin memastikan pengguna kembali ke login page saat sign out dari mana saja:
        // navigatorKey.currentState?.pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (_) => const LoginPage()),
        //   (route) => false,
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 5. Set navigatorKey di MaterialApp
      title: 'KopiQu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        // Pertimbangkan untuk memindahkan primaryColor ke colorScheme
        // primarySwatch: Colors.brown, // Contoh jika Anda ingin tema coklat
      ),
      home: const LoginPage(), // Halaman awal aplikasi
      routes: {
        '/menu': (context) => const MenuPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang': (context) => KeranjangScreen(),
        '/periksa': (context) => const PeriksaPesananScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/login':
            (context) =>
                const LoginPage(), // Rute eksplisit ke login jika perlu
        // Anda tidak perlu rute untuk ResetPasswordPage di sini karena navigasi dilakukan
        // secara programatik dari listener menggunakan navigatorKey.
      },
    );
  }
}
