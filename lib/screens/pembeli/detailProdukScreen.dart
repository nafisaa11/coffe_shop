import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart'; // Pastikan path model Kopi benar
import 'package:kopiqu/widgets/DetailKopi/detailKopi_widget.dart'; // Path ke DetailWidget
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class DetailProdukScreen extends StatefulWidget {
  final int id;

  DetailProdukScreen({super.key, required this.id});

  @override
  State<DetailProdukScreen> createState() => _DetailProdukScreenState();
}

class _DetailProdukScreenState extends State<DetailProdukScreen> {
  Kopi? _kopi; // Kopi bisa null sampai data berhasil diambil
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchKopiDetail();
  }

  Future<void> _fetchKopiDetail() async {
    // Set state awal sebelum fetching
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('kopi') // Nama tabel Anda
          .select()   // Pilih semua kolom (atau tentukan kolom yang dibutuhkan)
          .eq('id', widget.id) // Filter berdasarkan ID
          .single(); // Mengharapkan satu baris data, error jika tidak ditemukan

      if (mounted) { // Pastikan widget masih ada di tree
        setState(() {
          _kopi = Kopi.fromMap(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String NError = "";
        if (e is PostgrestException && e.code == 'PGRST116') {
             NError = 'Produk kopi tidak ditemukan.';
          } else {
             NError = 'Gagal memuat detail kopi: ${e.toString()}';
          }

        setState(() {
          _isLoading = false;
          _errorMessage = NError; // Simpan pesan error
        });
        print('Error fetching Kopi detail: $e'); // Untuk debugging
      }
    }
  }

  // Fungsi tambahKeKeranjang tetap sama atau sesuaikan dengan logika KeranjangController Anda
  void tambahKeKeranjang(BuildContext context, String ukuran) {
    if (_kopi == null) return; // Jangan lakukan apa-apa jika _kopi masih null

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ditambahkan: ${_kopi!.nama_kopi} ukuran $ukuran ke keranjang'),
      ),
    );
    // Di sini Anda bisa memanggil Provider.of<KeranjangController>(context, listen: false).tambah(_kopi!, ukuran);
    // jika DetailWidget tidak melakukannya secara internal.
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        // Tampilkan AppBar sederhana saat loading agar ada tombol kembali jika diperlukan
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.brown),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.brown),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchKopiDetail, // Tombol untuk mencoba lagi
                  child: const Text('Coba Lagi'),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_kopi == null) {
      // Kasus ini seharusnya sudah ditangani oleh _errorMessage jika fetching gagal
      // Namun, sebagai fallback jika _kopi tetap null tanpa error message.
      return Scaffold(
        appBar: AppBar(title: const Text('Tidak Ditemukan')),
        body: const Center(child: Text('Detail produk tidak tersedia.')),
      );
    }

    // Jika data berhasil dimuat (_kopi tidak null)
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              // Menggunakan Image.network jika gambar adalah URL
              // Tambahkan errorBuilder dan loadingBuilder untuk UX yang lebih baik
              _kopi!.gambar.startsWith('http')
                ? Image.network(
                    _kopi!.gambar,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 280,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        height: 280,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400], size: 60),
                      );
                    },
                  )
                : Image.asset( // Fallback jika bukan URL atau untuk placeholder lokal
                    _kopi!.gambar, // Pastikan path asset ini valid jika digunakan
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                     errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return Container(
                        height: 280,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400], size: 60),
                      );
                    },
                  ),
              Positioned(
                top: 40, // Sesuaikan posisi dengan status bar dan notch
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.brown),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16, // Tambahkan right padding agar teks tidak terlalu mepet
                child: Text(
                  _kopi!.nama_kopi, // Gunakan nama_kopi sesuai model
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0,1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: DetailWidget(
              kopi: _kopi!,
              // Pastikan `onTambah` di DetailWidget sesuai dengan apa yang Anda inginkan.
              // Jika DetailWidget menggunakan Provider untuk tambah ke keranjang,
              // callback ini mungkin hanya untuk notifikasi tambahan atau bisa disederhanakan.
              onTambah: (ukuran) => tambahKeKeranjang(context, ukuran),
            ),
          ),
        ],
      ),
    );
  }
}