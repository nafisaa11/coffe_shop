import 'package:flutter/material.dart';
import 'package:kopiqu/models/keranjang.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KeranjangItem> _keranjang = [];
  List<KeranjangItem> get keranjang =>
      _keranjang; // Kembalikan List<KeranjangItem>

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool sudahAda(Kopi kopi, String ukuran) {
    return _keranjang.any(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );
  }

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
        // Pastikan newIndex bukan item yang sama
        _keranjang[newIndex].jumlah += currentItem.jumlah;
        _keranjang.removeAt(index);
      } else if (newIndex == -1) {
        // Hanya ubah jika newIndex tidak ditemukan (atau sama dengan index saat ini jika tidak ada perubahan)
        currentItem.ukuran = newUkuran;
      }
      // Jika newIndex == index, berarti tidak ada perubahan ukuran yang berarti, tidak perlu lakukan apa-apa
      notifyListeners();
    }
  }

  // Di KeranjangController, perbaiki method tambahKeSupabase
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
      // Cek apakah item sudah ada
      final existingResponse =
          await _supabase
              .from('keranjang')
              .select('id, jumlah')
              .eq('id_user', currentUser.id)
              .eq('id_kopi', kopi.id)
              .eq('ukuran', ukuran)
              .maybeSingle();

      if (existingResponse != null) {
        // Update jumlah jika sudah ada
        await _supabase
            .from('keranjang')
            .update({'jumlah': existingResponse['jumlah'] + 1})
            .eq('id', existingResponse['id']);
      } else {
        // Insert baru jika belum ada
        await _supabase.from('keranjang').insert({
          'id_user': currentUser.id,
          'id_kopi': kopi.id,
          'ukuran': ukuran,
          'jumlah': 1,
          'dipilih': true,
        });
      }

      // Refresh data setelah menambah
      await fetchKeranjangItems();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal menambah item: ${e.toString()}";
      print("Error tambahKeSupabase: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method tambah() untuk kompatibilitas, tapi redirect ke Supabase
  void tambah(Kopi kopi, String ukuran) {
    tambahKeSupabase(kopi, ukuran);
  }

  // Method untuk hapus item dari Supabase
  Future<void> hapusKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('id_kopi', kopi.id)
          .eq('ukuran', ukuran);

      await fetchKeranjangItems(); // Refresh data
    } catch (e) {
      _errorMessage = "Gagal menghapus item: ${e.toString()}";
      notifyListeners();
      print("Error hapusKeSupabase: $e");
    }
  }

  // Method untuk ubah jumlah di Supabase
  Future<void> ubahJumlahDiSupabase(Kopi kopi, String ukuran, int delta) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      // Cari item terlebih dahulu
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
        // Hapus jika jumlah menjadi 0 atau kurang
        await _supabase
            .from('keranjang')
            .delete()
            .eq('id', existingResponse['id']);
      } else {
        // Update jumlah
        await _supabase
            .from('keranjang')
            .update({'jumlah': newJumlah})
            .eq('id', existingResponse['id']);
      }

      await fetchKeranjangItems(); // Refresh data
    } catch (e) {
      _errorMessage = "Gagal mengubah jumlah: ${e.toString()}";
      notifyListeners();
      print("Error ubahJumlahDiSupabase: $e");
    }
  }

  // Update method lama untuk redirect ke Supabase
  void hapus(Kopi kopi, String ukuran) {
    hapusKeSupabase(kopi, ukuran);
  }

  void ubahJumlah(Kopi kopi, String ukuran, int delta) {
    ubahJumlahDiSupabase(kopi, ukuran, delta);
  }

  Future<void> togglePilihDiSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    // Cari item di list lokal dulu untuk mendapatkan status 'dipilih' saat ini
    final itemIndex = _keranjang.indexWhere(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );
    if (itemIndex != -1) {
      final itemToToggle = _keranjang[itemIndex];
      final newStatusDipilih = !itemToToggle.dipilih;
      try {
        await _supabase
            .from('keranjang')
            .update({'dipilih': newStatusDipilih})
            .eq('id_user', currentUser.id)
            .eq('id_kopi', kopi.id) // Asumsi model Kopi punya 'id'
            .eq('ukuran', ukuran);

        // Update lokal juga atau fetch ulang
        itemToToggle.dipilih = newStatusDipilih;
        notifyListeners();
        // atau await fetchKeranjangItems();
      } catch (e) {
        _errorMessage = "Gagal mengubah status pilihan: ${e.toString()}";
        notifyListeners();
        print("Error togglePilihDiSupabase: $e");
      }
    }
  }

  // Method untuk pilih semua di Supabase
  Future<void> pilihSemuaDiSupabase(bool value) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase
          .from('keranjang')
          .update({'dipilih': value})
          .eq('id_user', currentUser.id);

      // Update lokal juga untuk responsivitas
      for (var item in _keranjang) {
        item.dipilih = value;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = "Gagal mengubah pilihan: ${e.toString()}";
      notifyListeners();
      print("Error pilihSemuaDiSupabase: $e");
    }
  }

  // Update method lama
  void pilihSemua(bool value) {
    pilihSemuaDiSupabase(value);
  }

  int get totalHarga {
    return _keranjang
        .where((item) => item.dipilih)
        .fold(0, (total, item) => total + (item.kopi.harga * item.jumlah));
  }

  // Method untuk membersihkan hanya item yang dipilih dari Supabase
  Future<void> bersihkanItemDipilihDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      // Hapus semua item yang dipilih (dipilih = true) dari Supabase
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('dipilih', true);

      // Refresh data setelah penghapusan
      await fetchKeranjangItems();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal membersihkan item dipilih: ${e.toString()}";
      notifyListeners();
      print("Error bersihkanItemDipilihDariSupabase: $e");
    }
  }

  // Update method bersihkanItemDipilih yang sudah ada
  void bersihkanItemDipilih() {
    // Panggil method yang menghapus dari Supabase
    bersihkanItemDipilihDariSupabase();
  }

  // Method untuk membersihkan seluruh keranjang dari Supabase
  Future<void> bersihkanKeranjangDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    try {
      await _supabase.from('keranjang').delete().eq('id_user', currentUser.id);

      // Clear local data
      _keranjang.clear();
      notifyListeners();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal membersihkan keranjang: ${e.toString()}";
      notifyListeners();
      print("Error bersihkanKeranjangDariSupabase: $e");
    }
  }

  // Update method bersihkanKeranjang yang sudah ada
  void bersihkanKeranjang() {
    bersihkanKeranjangDariSupabase();
  }

  // Method untuk mendapatkan item yang dipilih saja
  List<KeranjangItem> get itemDipilih {
    // Kembalikan List<KeranjangItem>
    return _keranjang.where((item) => item.dipilih).toList();
  }

  // Method untuk menghitung total item yang dipilih
  int get totalItemDipilih {
    int total = 0;
    for (var item in _keranjang) {
      if (item.dipilih) {
        total += item.jumlah;
      }
    }
    return total;
  }

  Future<void> fetchKeranjangItems() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _keranjang = []; // Kosongkan keranjang jika tidak ada user
      _errorMessage = "Pengguna belum login.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Query ke Supabase untuk mengambil item keranjang milik user saat ini
      // dan melakukan JOIN (atau nested select) dengan tabel kopi
      final response = await _supabase
          .from(
            'keranjang',
          ) // Ganti dengan nama tabel keranjang Anda di Supabase
          .select(''' 
            id, 
            id_user,
            id_kopi,
            ukuran,
            jumlah,
            dipilih,
            kopi:id_kopi (id, nama_kopi, harga, gambar, komposisi, deskripsi) 
          ''') // Nested select untuk mengambil detail kopi terkait
          .eq('id_user', currentUser.id);

      if (response is List) {
        // Pastikan respons adalah list
        _keranjang =
            response
                .map((itemData) {
                  final kopiData = itemData['kopi'];
                  if (kopiData == null) {
                    // Handle kasus di mana data kopi tidak ditemukan (seharusnya tidak terjadi jika foreign key benar)
                    print(
                      'Data Kopi tidak ditemukan untuk item keranjang: ${itemData['id']}',
                    );
                    // Anda bisa melempar error atau mengembalikan KeranjangItem dengan Kopi placeholder
                    // Untuk saat ini, kita akan mengabaikan item ini atau membuat Kopi default.
                    // Pilihan terbaik adalah memastikan data konsisten.
                    // Atau, filter item yang kopiData-nya null:
                    return null;
                  }
                  return KeranjangItem(
                    // Anda mungkin perlu menambahkan cart_item_id ke model KeranjangItem jika ingin memanipulasinya berdasarkan ID unik dari tabel keranjang
                    kopi: Kopi.fromMap(
                      kopiData as Map<String, dynamic>,
                    ), // Pastikan Kopi.fromMap ada
                    ukuran: itemData['ukuran'] as String,
                    jumlah: itemData['jumlah'] as int,
                    dipilih: itemData['dipilih'] as bool,
                  );
                })
                .whereType<KeranjangItem>()
                .toList(); // Filter item yang null (jika kopiData tidak ditemukan)
      } else {
        // Handle jika format respons tidak sesuai
        _keranjang = [];
        _errorMessage = "Format data keranjang tidak valid.";
        print('Unexpected response format for keranjang items: $response');
      }
    } catch (e) {
      _errorMessage = "Gagal memuat keranjang: ${e.toString()}";
      print('Error fetching keranjang from Supabase: $e');
      _keranjang = []; // Kosongkan keranjang jika ada error
    }

    _isLoading = false;
    notifyListeners();
  }

  bool get semuaDipilih => _keranjang.every((item) => item.dipilih);
}
