// controllers/Keranjang_Controller.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/models/keranjang.dart'; // Pastikan path dan nama model KeranjangItem Anda benar
import 'package:kopiqu/models/kopi.dart'; // Pastikan path model Kopi Anda benar
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KeranjangItem> _keranjang = [];

  List<KeranjangItem> get keranjang => _keranjang;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItemDiKeranjang {
    int total = 0;
    for (var item in _keranjang) {
      total += item.jumlah;
    }
    return total;
  }

  // METHOD BARU (atau pastikan sudah ada) untuk membersihkan state lokal
  void clearLocalCartAndResetState() {
    _keranjang = [];
    _isLoading = false;
    _errorMessage = null;
    print('[KeranjangController] Local cart and states have been reset.');
    notifyListeners();
  }

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
        _keranjang[newIndex].jumlah += currentItem.jumlah;
        _keranjang.removeAt(index);
      } else if (newIndex == -1) {
        currentItem.ukuran = newUkuran;
      }
      notifyListeners();
      // TODO: Pertimbangkan untuk update perubahan ukuran ke Supabase jika diperlukan
    }
  }

  Future<void> tambahKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _errorMessage = "Pengguna belum login.";
      notifyListeners();
      return;
    }

    if (!_isLoading) {
      // Hanya set isLoading jika belum loading
      _isLoading = true;
      notifyListeners();
    }

    try {
      final existingResponse =
          await _supabase
              .from('keranjang')
              .select('id, jumlah')
              .eq('id_user', currentUser.id)
              .eq('id_kopi', kopi.id)
              .eq('ukuran', ukuran)
              .maybeSingle();

      if (existingResponse != null) {
        await _supabase
            .from('keranjang')
            .update({'jumlah': existingResponse['jumlah'] + 1})
            .eq('id', existingResponse['id']);
        print('[KeranjangController] Jumlah item di Supabase diupdate.');
      } else {
        await _supabase.from('keranjang').insert({
          'id_user': currentUser.id,
          'id_kopi': kopi.id,
          'ukuran': ukuran,
          'jumlah': 1,
          'dipilih': true,
        });
        print('[KeranjangController] Item baru ditambahkan ke Supabase.');
      }
      _errorMessage = null; // Hapus error jika sukses
      await fetchKeranjangItems(); // Refresh setelah operasi DB
    } catch (e) {
      _errorMessage = "Gagal menambah item: ${e.toString()}";
      print("[KeranjangController] Error tambahKeSupabase: $e");
      // notifyListeners(); // fetchKeranjangItems akan memanggil notifyListeners
    } finally {
      // Pastikan isLoading selalu kembali ke false
      if (_isLoading) {
        // Hanya set false jika sebelumnya true
        _isLoading = false;
        notifyListeners(); // Notify perubahan isLoading
      }
    }
  }

  void tambah(Kopi kopi, String ukuran) {
    tambahKeSupabase(kopi, ukuran);
  }

  Future<void> hapusKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('id_kopi', kopi.id)
          .eq('ukuran', ukuran);
      _errorMessage = null;
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal menghapus item: ${e.toString()}";
      print("[KeranjangController] Error hapusKeSupabase: $e");
      // notifyListeners(); // fetchKeranjangItems akan memanggil notifyListeners
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void hapus(Kopi kopi, String ukuran) {
    hapusKeSupabase(kopi, ukuran);
  }

  Future<void> ubahJumlahDiSupabase(Kopi kopi, String ukuran, int delta) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
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
      _errorMessage = null;
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal mengubah jumlah: ${e.toString()}";
      print("[KeranjangController] Error ubahJumlahDiSupabase: $e");
      // notifyListeners(); // fetchKeranjangItems akan memanggil notifyListeners
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
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
      // Optimistic update: update lokal dulu untuk responsivitas UI
      itemToToggle.dipilih = newStatusDipilih;
      notifyListeners();

      try {
        await _supabase
            .from('keranjang')
            .update({'dipilih': newStatusDipilih})
            .eq('id_user', currentUser.id)
            .eq('id_kopi', kopi.id)
            .eq('ukuran', ukuran);
        _errorMessage = null;
        // Tidak perlu fetchKeranjangItems() jika hanya update 'dipilih' dan sudah optimis
      } catch (e) {
        // Rollback jika gagal
        itemToToggle.dipilih = !newStatusDipilih;
        _errorMessage = "Gagal mengubah status pilihan: ${e.toString()}";
        print("[KeranjangController] Error togglePilihDiSupabase: $e");
        notifyListeners();
      }
    }
  }

  Future<void> pilihSemuaDiSupabase(bool value) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    // Optimistic update
    for (var item in _keranjang) {
      item.dipilih = value;
    }
    notifyListeners();

    try {
      await _supabase
          .from('keranjang')
          .update({'dipilih': value})
          .eq('id_user', currentUser.id);
      _errorMessage = null;
      // Tidak perlu fetch jika sudah update lokal semua
    } catch (e) {
      // Rollback jika gagal
      for (var item in _keranjang) {
        item.dipilih = !value;
      }
      _errorMessage = "Gagal mengubah semua pilihan: ${e.toString()}";
      print("[KeranjangController] Error pilihSemuaDiSupabase: $e");
      notifyListeners();
    }
  }

  void pilihSemua(bool value) {
    pilihSemuaDiSupabase(value);
  }

  int get totalHarga {
    int currentTotal = 0;
    for (var item in _keranjang) {
      if (item.dipilih) {
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

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_user', currentUser.id)
          .eq('dipilih', true);
      _errorMessage = null;
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal membersihkan item dipilih: ${e.toString()}";
      print("[KeranjangController] Error bersihkanItemDipilihDariSupabase: $e");
      // notifyListeners(); // fetchKeranjangItems akan memanggil notifyListeners
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void bersihkanItemDipilih() {
    bersihkanItemDipilihDariSupabase();
  }

  Future<void> bersihkanKeranjangDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      await _supabase.from('keranjang').delete().eq('id_user', currentUser.id);
      // Data lokal akan dibersihkan oleh fetchKeranjangItems yang dipanggil setelahnya
      // atau oleh clearLocalCartAndResetState jika logout
      _errorMessage = null;
      await fetchKeranjangItems(); // Panggil fetch untuk update _keranjang menjadi []
    } catch (e) {
      _errorMessage = "Gagal membersihkan keranjang: ${e.toString()}";
      print("[KeranjangController] Error bersihkanKeranjangDariSupabase: $e");
      // notifyListeners(); // fetchKeranjangItems akan memanggil notifyListeners
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
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

  Future<void> fetchKeranjangItems() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      if (_keranjang.isNotEmpty || _isLoading || _errorMessage != null) {
        clearLocalCartAndResetState(); // Gunakan method reset yang lebih komprehensif
      }
      print(
        '[KeranjangController] No user logged in. Cart state reset by fetch.',
      );
      return;
    }

    // Hanya set isLoading jika belum loading, untuk menghindari pemanggilan notifyListeners berlebihan
    bool needsToNotifyLoading = false;
    if (!_isLoading) {
      _isLoading = true;
      needsToNotifyLoading =
          true; // Tandai bahwa kita perlu notify untuk status loading
    }
    _errorMessage = null; // Selalu reset error message di awal fetch
    if (needsToNotifyLoading) {
      notifyListeners(); // Notify listener bahwa loading dimulai
    }

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
                  return KeranjangItem(
                    kopi: Kopi.fromMap(kopiData as Map<String, dynamic>),
                    ukuran: itemData['ukuran'] as String,
                    jumlah: itemData['jumlah'] as int,
                    dipilih: itemData['dipilih'] as bool,
                    // Anda bisa tambahkan ID item keranjang dari Supabase jika perlu
                    // id: itemData['id'] as int, // atau String jika UUID
                  );
                })
                .whereType<KeranjangItem>()
                .toList();
        _errorMessage = null; // Hapus error jika sukses
        print(
          '[KeranjangController] Keranjang berhasil di-fetch. Item unik: ${_keranjang.length}, Total kuantitas: $totalItemDiKeranjang',
        );
      } else {
        _keranjang = []; // Jika respons bukan list, anggap keranjang kosong
        _errorMessage = "Format data keranjang tidak valid dari server.";
        print(
          '[KeranjangController] Unexpected response format for keranjang items: $response',
        );
      }
    } catch (e) {
      _errorMessage = "Gagal memuat keranjang: ${e.toString()}";
      print('[KeranjangController] Error fetching keranjang from Supabase: $e');
      _keranjang = []; // Kosongkan keranjang jika ada error
    } finally {
      if (_isLoading) {
        // Hanya set false jika sebelumnya true
        _isLoading = false;
        notifyListeners(); // Notify listener bahwa loading selesai dan data (mungkin) berubah
      } else if (needsToNotifyLoading == false &&
          (_keranjang.isNotEmpty || _errorMessage != null)) {
        // Jika tidak ada perubahan status loading tapi ada perubahan data/error, tetap notify
        notifyListeners();
      }
    }
  }

  bool get semuaDipilih =>
      _keranjang.isNotEmpty && _keranjang.every((item) => item.dipilih);
}
