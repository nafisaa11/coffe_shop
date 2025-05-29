import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/keranjangScreen.dart'; // Pastikan ini benar PeriksaPesananScreen atau KeranjangScreen?
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:kopiqu/screens/transaksiScreen.dart'; // Ini adalah PeriksaPesananScreen, sudah di-import di routes
import 'package:kopiqu/services/cart_ui_service.dart';
// import 'package:kopiqu/screens/periksa_pesanan_screen.dart'; // Nama file dari kode struk Anda
import 'package:kopiqu/services/getKopi_servce.dart'; // Tidak digunakan di sini, hapus jika tidak perlu
import 'package:provider/provider.dart';
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/admin/admindashboard.dart';
import 'package:kopiqu/screens/resetpasswordpage.dart';

// ❗️ PENTING: Import untuk lokalisasi intl
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  // Wajib: inisialisasi Flutter sebelum async
  WidgetsFlutterBinding.ensureInitialized();

  // ❗️ PENTING: Inisialisasi data lokalisasi untuk 'id_ID'
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://xuivlesfrjbjtaaavtma.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1aXZsZXNmcmpianRhYWF2dG1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyODc3OTgsImV4cCI6MjA2Mjg2Mzc5OH0.g33UOprpbbVXqpXtP3tY2nedOeCZklO003S4aZrUQsE',
  );

  // Jalankan aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => KeranjangController()),
      ChangeNotifierProvider(create: (_) => CartUIService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print("Auth Event di MyApp: $event");

      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        final userEmail = session.user?.email;
        print("Password Recovery event diterima untuk email: $userEmail");
        if (userEmail != null) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(email: userEmail),
            ),
            (route) => false,
          );
        } else {
          print(
            "Email pengguna tidak ditemukan di session setelah password recovery.",
          );
        }
      } else if (event == AuthChangeEvent.signedIn) {
        print("User signed in: ${session?.user?.email}");
      } else if (event == AuthChangeEvent.signedOut) {
        print("User signed out");
        // Contoh navigasi ke login setelah sign out, jika diperlukan:
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
      navigatorKey: navigatorKey,
      title: 'KopiQu',
      // ❗️ PENTING: Konfigurasi Lokalisasi
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Untuk Bahasa Indonesia
        // Locale('en', 'US'), // Jika Anda mendukung bahasa lain
      ],
      locale: const Locale('id', 'ID'), // Atur locale default aplikasi Anda

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        // primarySwatch: Colors.brown, // Anda bisa aktifkan ini jika mau tema dasar coklat
      ),
      home: AuthGate(),
      routes: {
        '/menu': (context) => MenuPage(),
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang':
            (context) =>
                KeranjangScreen(), // Ini halaman daftar item di keranjang
        '/periksa':
            (context) =>
                const PeriksaPesananScreen(), // Ini halaman Periksa Pesanan/Transaksi
        '/admin': (context) => const AdminDashboardScreen(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return const MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
