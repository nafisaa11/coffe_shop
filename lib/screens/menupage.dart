import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart'; // Pastikan path model Kopi benar
import 'package:kopiqu/widgets/Layout/header_widget.dart';
import 'package:kopiqu/widgets/Homepage/kopiCard_widget.dart'; // Pastikan path CoffeeCard benar
import 'package:kopiqu/widgets/Homepage/search_widget.dart';
import 'package:kopiqu/widgets/Homepage/tag_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class MenuPage extends StatefulWidget {
  MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Kopi> _kopiList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchKopiData();
  }

  Future<void> _fetchKopiData() async {
    try {
      // Set loading true di awal dan hapus error message sebelumnya
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('kopi') // Nama tabel Anda
          .select();   // Mengambil semua kolom

      // Supabase mengembalikan List<Map<String, dynamic>>
      // Kopi.listFromJson sudah dirancang untuk menangani List<dynamic>
      if (mounted) { // Pastikan widget masih ada di tree sebelum update state
        setState(() {
          _kopiList = Kopi.listFromJson(response as List<dynamic>);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data kopi: ${e.toString()}';
          print('Error fetching kopi data: $e'); // Untuk debugging
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red[700])),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchKopiData, // Tombol untuk mencoba lagi
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    } else if (_kopiList.isEmpty) {
      bodyContent = const Center(child: Text('Tidak ada produk kopi yang tersedia saat ini.'));
    } else {
      // Struktur CustomScrollView jika data berhasil dimuat
      bodyContent = CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchWidget(), // Pastikan SearchWidget tidak memerlukan _kopiList secara langsung di sini
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: TagList()), // Sama untuk TagList
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Sesuaikan childAspectRatio jika perlu
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CoffeeCard(kopi: _kopiList[index]); // Menggunakan _kopiList
                },
                childCount: _kopiList.length, // Menggunakan panjang _kopiList
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)), // Padding bawah jika perlu
        ],
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100), // Padding untuk KopiQuHeader
            child: bodyContent, // Konten dinamis (loading, error, atau daftar kopi)
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: KopiQuHeader(), // Header tetap di atas
          ),
        ],
      ),
    );
  }
}