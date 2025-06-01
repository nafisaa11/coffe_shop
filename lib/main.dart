// main.dart
import 'dart:async'; // 👈 1. IMPORT dart:async untuk StreamSubscription
import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart'; // 👈 2. IMPORT KeranjangController
import 'package:kopiqu/services/cart_ui_service.dart';
import 'package:provider/provider.dart'; // 👈 2. IMPORT Provider
import 'package:kopiqu/screens/Homepage.dart';
import 'package:kopiqu/screens/keranjangScreen.dart';
import 'package:kopiqu/screens/loginpage.dart';
import 'package:kopiqu/screens/mainscreen.dart';
import 'package:kopiqu/screens/transaksiScreen.dart'; // Nama file Anda adalah transaksiScreen.dart, pastikan konsisten
import 'package:kopiqu/screens/profile_page.dart';
import 'package:kopiqu/screens/menupage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/screens/resetpasswordpage.dart';
import 'package:kopiqu/screens/admin/admin_mainscreen.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: 'https://xuivlesfrjbjtaaavtma.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1aXZsZXNmcmpianRhYWF2dG1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyODc3OTgsImV4cCI6MjA2Mjg2Mzc5OH0.g33UOprpbbVXqpXtP3tY2nedOeCZklO003S4aZrUQsE',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KeranjangController()),
        ChangeNotifierProvider(create: (_) => CartUIService()),
      ],
      child: const MyApp(), // MyApp sekarang const
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
  StreamSubscription<AuthState>?
  _authSubscription; // 👈 3. Definisikan StreamSubscription

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription
        ?.cancel(); // 👈 4. Batalkan listener saat MyApp di-dispose
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription
        ?.cancel(); // Batalkan listener lama jika ada sebelum membuat yang baru
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print(
        "[MyApp - AuthListener] Event: $event, Session User ID: ${session?.user?.id}",
      );

      // Gunakan navigatorKey.currentContext untuk mendapatkan context yang valid
      // yang bisa mengakses Provider yang didefinisikan di atas MaterialApp.
      final BuildContext? currentNavigatorContext = navigatorKey.currentContext;

      if (currentNavigatorContext == null) {
        print(
          "[MyApp - AuthListener] Navigator context is null. Skipping KeranjangController interaction.",
        );
        // Handle event navigasi lain jika perlu tanpa context Provider
        if (event == AuthChangeEvent.passwordRecovery && session != null) {
          final userEmail = session.user?.email;
          print(
            "[MyApp - AuthListener] Password Recovery for email (no context): $userEmail",
          );
          if (userEmail != null) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => ResetPasswordPage(email: userEmail),
              ),
              (route) => false,
            );
          }
        }
        return; // Keluar jika context tidak ada
      }

      // 👇 5. LOGIKA UNTUK KERANJANG CONTROLLER
      try {
        if (event == AuthChangeEvent.signedIn && session != null) {
          print(
            '[MyApp - AuthListener] User SIGNED IN (${session.user.id}). Fetching cart items.',
          );
          Provider.of<KeranjangController>(
            currentNavigatorContext,
            listen: false,
          ).fetchKeranjangItems();
        } else if (event == AuthChangeEvent.signedOut) {
          print(
            '[MyApp - AuthListener] User SIGNED OUT. Clearing local cart state.',
          );
          Provider.of<KeranjangController>(
            currentNavigatorContext,
            listen: false,
          ).clearLocalCartAndResetState();
          // Navigasi ke login page jika belum dihandle oleh AuthGate
          // Biasanya AuthGate sudah menangani ini, tapi bisa ditambahkan di sini jika perlu
          // navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        } else if (event == AuthChangeEvent.userUpdated) {
          print(
            '[MyApp - AuthListener] User data UPDATED. ProfileHeader will refresh itself. Cart may not need immediate refresh unless user ID changed.',
          );
          // ProfileHeader sudah punya listener sendiri.
          // Untuk keranjang, biasanya tidak perlu fetch ulang hanya karena metadata user berubah,
          // kecuali jika ada logika spesifik yang bergantung pada itu.
        }
      } catch (e) {
        print(
          "[MyApp - AuthListener] Error interacting with KeranjangController: $e",
        );
        // Ini bisa terjadi jika Provider belum sepenuhnya siap atau context tidak valid
        // pada momen tertentu.
      }

      // Logika navigasi untuk password recovery (sudah ada)
      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        final userEmail = session.user?.email;
        print(
          "[MyApp - AuthListener] Password Recovery event for email: $userEmail",
        );
        if (userEmail != null) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(email: userEmail),
            ),
            (route) => false,
          );
        } else {
          print(
            "[MyApp - AuthListener] Email not found in session after password recovery.",
          );
        }
      }
      // Anda bisa menambahkan logika navigasi lain di sini jika diperlukan,
      // tapi AuthGate Anda sudah menangani navigasi utama berdasarkan status sesi.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:
          navigatorKey, // Penting agar kita bisa mendapatkan context dari navigatorKey
      title: 'KopiQu',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(
            255,
            0,
            0,
            0,
          ), // Anda menggunakan hitam sebagai seedColor
        ),
        // primarySwatch: Colors.brown, // Anda bisa uncomment ini jika ingin tema coklat
      ),
      home:
          const AuthGate(), // AuthGate akan menangani tampilan awal (LoginPage atau MainScreen)
      routes: {
        '/menu':
            (context) =>
                const MenuPage(), // Pastikan semua page widget bisa const jika tidak ada parameter
        '/home': (context) => const Homepage(),
        '/profile': (context) => const ProfilePage(),
        '/keranjang': (context) => KeranjangScreen(),
        '/periksa':
            (context) =>
                const PeriksaPesananScreen(), // Nama file Anda: transaksiScreen.dart
        '/admin': (context) => const AdminMainScreen(),
        '/login': (context) => const LoginPage(),
        // Rute untuk MainScreen jika perlu diakses dengan nama, meskipun AuthGate sudah mengarahkannya
        '/home_main': (context) => const MainScreen(),
      },
    );
  }
}

// AuthGate Anda (tampaknya sudah baik, saya hanya merapikan sedikit)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          // Tampilkan loading hanya jika belum ada data sesi awal (misal saat restore session)
          print('AuthGate: ConnectionState.waiting, no initial data yet.');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika sudah ada data (meskipun mungkin session null), kita bisa proses
        final session = snapshot.data?.session;

        if (session != null && session.user != null) {
          final user = session.user!;
          final userRole = user.userMetadata?['role'] as String?;
          final userEmail = user.email ?? "";

          print('AuthGate: Session active. Role: $userRole, Email: $userEmail');

          if (userRole == 'admin' && userEmail.endsWith('@kopiqu.com')) {
            // Penting: Hindari navigasi berulang jika sudah di halaman yang benar.
            // Karena AuthGate adalah home, ia akan rebuild saat state berubah.
            // Langsung return widget lebih aman daripada pushReplacementNamed dari sini.
            return const AdminMainScreen();
          } else if (userRole == 'pembeli') {
            return const MainScreen();
          } else {
            print(
              'AuthGate: Role tidak dikenali ($userRole) atau email admin salah. Arahkan ke LoginPage.',
            );
            // Pertimbangkan untuk signOut jika role tidak valid agar tidak terjebak
            // Future.microtask(() => Supabase.instance.client.auth.signOut()); // Akan memicu rebuild AuthGate
            return const LoginPage();
          }
        } else {
          print('AuthGate: No active session. Showing LoginPage.');
          return const LoginPage();
        }
      },
    );
  }
}
