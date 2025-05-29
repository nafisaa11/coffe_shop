// controllers/Keranjang_Controller.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/models/keranjang.dart'; // Pastikan path dan nama model KeranjangItem Anda benar
import 'package:kopiqu/models/kopi.dart'; // Pastikan path model Kopi Anda benar
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KeranjangItem> _keranjang =
      []; // Daftar item keranjang lokal, di-update dari Supabase

  // Getter untuk mengakses daftar item keranjang dari luar controller
  List<KeranjangItem> get keranjang => _keranjang;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter BARU: Untuk menghitung total KUANTITAS semua item di keranjang
  // Ini akan digunakan untuk badge pada ikon keranjang.
  int get totalItemDiKeranjang {
    int total = 0;
    for (var item in _keranjang) {
      total += item.jumlah; // Asumsi KeranjangItem punya field 'jumlah'
    }
    return total;
  }

  // Method untuk mengecek apakah item dengan ukuran tertentu sudah ada di keranjang lokal
  // Mungkin tidak terlalu relevan jika semua pengecekan dilakukan di Supabase,
  // tapi bisa berguna untuk UI sebelum panggil Supabase.
  bool sudahAda(Kopi kopi, String ukuran) {
    return _keranjang.any(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );
  }

  // Method ubahUkuran (lokal) - Jika Anda ingin mengubah ukuran item yang sudah ada di keranjang
  // sebelum disinkronkan atau jika ada logika UI khusus.
  // Perhatikan bahwa operasi utama Anda sudah langsung ke Supabase.
  void ubahUkuran(Kopi kopi, String oldUkuran, String newUkuran) {
    final index = _keranjang.indexWhere(
      (item) => item.kopi.id == kopi.id && item.ukuran == oldUkuran,
    );

    if (index != -1) {
      final currentItem = _keranjang[index];
      final newIndex = _keranjang.indexWhere(
        (item) => item.kopi.id == kopi.id && item.ukuran == newUkuran,
      );

      if (newIndex != -1 && newIndex != index) {
        _keranjang[newIndex].jumlah += currentItem.jumlah;
        _keranjang.removeAt(index);
      } else if (newIndex == -1) {
        currentItem.ukuran = newUkuran;
      }
      notifyListeners();
      // PERTIMBANGKAN: Apakah perubahan ukuran ini juga perlu di-update ke Supabase?
      // Jika iya, Anda perlu method seperti `updateUkuranDiSupabase`
    }
  }

  // Method untuk menambah item ke keranjang di Supabase.
  // Ini akan dipanggil saat tombol "plus" ditekan di halaman menu.
  Future<void> tambahKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _errorMessage = "Pengguna belum login.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final existingResponse =
          await _supabase
              .from('keranjang')
              .select('id, jumlah')
              .eq('id_user', currentUser.id)
              .eq('id_kopi', kopi.id)
              .eq('ukuran', ukuran)
              .maybeSingle(); // Mengambil satu baris atau null jika tidak ada

      if (existingResponse != null) {
        // Jika item sudah ada, update jumlahnya
        await _supabase
            .from('keranjang')
            .update({'jumlah': existingResponse['jumlah'] + 1})
            .eq('id', existingResponse['id']);
        print('[KeranjangController] Jumlah item di Supabase diupdate.');
      } else {
        // Jika item belum ada, insert item baru
        await _supabase.from('keranjang').insert({
          'id_user': currentUser.id,
          'id_kopi': kopi.id,
          'ukuran': ukuran,
          'jumlah': 1,
          'dipilih': true, // Default item terpilih saat ditambahkan
        });
        print('[KeranjangController] Item baru ditambahkan ke Supabase.');
      }

      await fetchKeranjangItems(); // Refresh data keranjang lokal dari Supabase
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal menambah item: ${e.toString()}";
      print("[KeranjangController] Error tambahKeSupabase: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method 'tambah' ini sudah ada dan memanggil 'tambahKeSupabase'.
  // Ini bisa digunakan oleh UI sebagai action utama penambahan item.
  void tambah(Kopi kopi, String ukuran) {
    tambahKeSupabase(kopi, ukuran);
  }

  // ... (method hapusKeSupabase, ubahJumlahDiSupabase, dll. tetap sama) ...
  // Pastikan semua method yang memodifikasi data di Supabase memanggil fetchKeranjangItems()
  // dan notifyListeners() agar UI (termasuk badge) terupdate.

  Future<void> hapusKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('id_kopi', kopi.id)
          .eq('ukuran', ukuran);
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal menghapus item: ${e.toString()}";
      print("[KeranjangController] Error hapusKeSupabase: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void hapus(Kopi kopi, String ukuran) {
    hapusKeSupabase(kopi, ukuran);
  }

  Future<void> ubahJumlahDiSupabase(Kopi kopi, String ukuran, int delta) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final existingResponse =
          await _supabase
              .from('keranjang')
              .select('id, jumlah')
              .eq('id_user', currentUser.id)
              .eq('id_kopi', kopi.id)
              .eq('ukuran', ukuran)
              .single();

      final newJumlah = existingResponse['jumlah'] + delta;

      if (newJumlah <= 0) {
        await _supabase
            .from('keranjang')
            .delete()
            .eq('id', existingResponse['id']);
      } else {
        await _supabase
            .from('keranjang')
            .update({'jumlah': newJumlah})
            .eq('id', existingResponse['id']);
      }
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal mengubah jumlah: ${e.toString()}";
      print("[KeranjangController] Error ubahJumlahDiSupabase: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void ubahJumlah(Kopi kopi, String ukuran, int delta) {
    ubahJumlahDiSupabase(kopi, ukuran, delta);
  }

  Future<void> togglePilihDiSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    final itemIndex = _keranjang.indexWhere(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );
    if (itemIndex != -1) {
      final itemToToggle = _keranjang[itemIndex];
      final newStatusDipilih = !itemToToggle.dipilih;
      _isLoading = true;
      notifyListeners();
      try {
        await _supabase
            .from('keranjang')
            .update({'dipilih': newStatusDipilih})
            .eq('id_user', currentUser.id)
            .eq('id_kopi', kopi.id)
            .eq('ukuran', ukuran);
        // Update lokal juga untuk responsivitas instan sebelum fetch
        itemToToggle.dipilih = newStatusDipilih;
        // await fetchKeranjangItems(); // Atau cukup update lokal dan notify
      } catch (e) {
        _errorMessage = "Gagal mengubah status pilihan: ${e.toString()}";
        print("[KeranjangController] Error togglePilihDiSupabase: $e");
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pilihSemuaDiSupabase(bool value) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase
          .from('keranjang')
          .update({'dipilih': value})
          .eq('id_user', currentUser.id);
      for (var item in _keranjang) {
        // Update lokal
        item.dipilih = value;
      }
    } catch (e) {
      _errorMessage = "Gagal mengubah pilihan: ${e.toString()}";
      print("[KeranjangController] Error pilihSemuaDiSupabase: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void pilihSemua(bool value) {
    pilihSemuaDiSupabase(value);
  }

  // Getter totalHarga Anda sudah ada, mungkin perlu disesuaikan jika harga item bervariasi berdasarkan ukuran
  // dan jika 'kopi.harga' adalah harga dasar sebelum penyesuaian ukuran.
  // Untuk saat ini kita biarkan.
  int get totalHarga {
    int currentTotal = 0;
    for (var item in _keranjang) {
      if (item.dipilih) {
        // Logika perhitungan harga di sini harus konsisten dengan bagaimana harga ditampilkan
        // dan dihitung di tempat lain (misal, PeriksaPesananScreen atau Transaksi.fromKeranjang)
        // Asumsi sementara, Kopi.harga adalah harga final untuk ukuran tersebut,
        // atau Anda perlu logika penyesuaian harga di sini.
        // Untuk sekarang, kita gunakan kopi.harga langsung.
        // Jika Kopi.harga adalah harga dasar, dan ukuran memodifikasinya:
        int hargaItem = item.kopi.harga;
        if (item.ukuran == 'Besar') {
          hargaItem += 5000;
        } else if (item.ukuran == 'Kecil') {
          hargaItem -= 3000;
          if (hargaItem < 0) hargaItem = 0;
        }
        currentTotal += (hargaItem * item.jumlah);
      }
    }
    return currentTotal;
  }

  Future<void> bersihkanItemDipilihDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('dipilih', true);
      await fetchKeranjangItems();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal membersihkan item dipilih: ${e.toString()}";
      print("[KeranjangController] Error bersihkanItemDipilihDariSupabase: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void bersihkanItemDipilih() {
    bersihkanItemDipilihDariSupabase();
  }

  Future<void> bersihkanKeranjangDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _supabase.from('keranjang').delete().eq('id_user', currentUser.id);
      _keranjang.clear(); // Langsung clear lokal setelah berhasil delete di DB
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal membersihkan keranjang: ${e.toString()}";
      print("[KeranjangController] Error bersihkanKeranjangDariSupabase: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void bersihkanKeranjang() {
    bersihkanKeranjangDariSupabase();
  }

  List<KeranjangItem> get itemDipilih {
    return _keranjang.where((item) => item.dipilih).toList();
  }

  int get totalItemDipilih {
    int total = 0;
    for (var item in _keranjang) {
      if (item.dipilih) {
        total += item.jumlah;
      }
    }
    return total;
  }

  // Method fetchKeranjangItems Anda sudah sangat baik dengan nested select.
  Future<void> fetchKeranjangItems() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _keranjang = [];
      _errorMessage = "Pengguna belum login.";
      // _isLoading tidak di-set true di sini, jadi tidak perlu false, tapi notifyListeners tetap penting
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listener bahwa loading dimulai

    try {
      final response = await _supabase
          .from('keranjang')
          .select(''' 
            id, 
            id_user,
            id_kopi,
            ukuran,
            jumlah,
            dipilih,
            kopi:id_kopi (id, nama_kopi, harga, gambar, komposisi, deskripsi) 
          ''')
          .eq('id_user', currentUser.id);

      if (response is List) {
        _keranjang =
            response
                .map((itemData) {
                  final kopiData = itemData['kopi'];
                  if (kopiData == null) {
                    print(
                      'Data Kopi tidak ditemukan untuk item keranjang: ${itemData['id']}',
                    );
                    return null;
                  }
                  // Buat objek KeranjangItem dengan ID keranjang (cart_item_id)
                  // jika model KeranjangItem Anda bisa menyimpannya.
                  // Misalnya: KeranjangItem(cartItemId: itemData['id'] as int, kopi: ..., dst.)
                  return KeranjangItem(
                    kopi: Kopi.fromMap(kopiData as Map<String, dynamic>),
                    ukuran: itemData['ukuran'] as String,
                    jumlah: itemData['jumlah'] as int,
                    dipilih: itemData['dipilih'] as bool,
                  );
                })
                .whereType<KeranjangItem>()
                .toList();
        print(
          '[KeranjangController] Keranjang berhasil di-fetch. Jumlah item unik: ${_keranjang.length}, Total kuantitas: $totalItemDiKeranjang',
        );
      } else {
        _keranjang = [];
        _errorMessage = "Format data keranjang tidak valid.";
        print(
          '[KeranjangController] Unexpected response format for keranjang items: $response',
        );
      }
    } catch (e) {
      _errorMessage = "Gagal memuat keranjang: ${e.toString()}";
      print('[KeranjangController] Error fetching keranjang from Supabase: $e');
      _keranjang = [];
    }

    _isLoading = false;
    notifyListeners(); // Notify listener bahwa loading selesai dan data (mungkin) berubah
  }

  bool get semuaDipilih =>
      _keranjang.isNotEmpty && _keranjang.every((item) => item.dipilih);
}
