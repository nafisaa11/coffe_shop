// controllers/keranjang/Keranjang_Controller.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/models/keranjang.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KeranjangController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KeranjangItem> _keranjang = [];
  List<KeranjangItem> _keranjangHabis = []; // Tambahan untuk item terjual habis
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<KeranjangItem> get keranjang => _keranjang;
  List<KeranjangItem> get keranjangHabis =>
      _keranjangHabis; // Getter untuk item habis
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SupabaseClient get supabase => _supabase;

  // Setters untuk state management
  void setKeranjang(List<KeranjangItem> keranjang) {
    _keranjang = keranjang;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setErrorMessage(String? error) {
    _errorMessage = error;
  }

  // Method untuk membersihkan state lokal
  void clearLocalCartAndResetState() {
    _keranjang = [];
    _keranjangHabis = [];
    _isLoading = false;
    _errorMessage = null;
    print('[KeranjangController] Local cart and states have been reset.');
    notifyListeners();
  }

  // ======== TAMBAH KERANJANG METHODS ========
  Future<void> _tambahKeSupabase(Kopi kopi, String ukuran) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _errorMessage = "Pengguna belum login.";
      notifyListeners();
      return;
    }

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

      _errorMessage = null;
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal menambah item: ${e.toString()}";
      print("[KeranjangController] Error tambahKeSupabase: $e");
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void tambah(Kopi kopi, String ukuran) {
    _tambahKeSupabase(kopi, ukuran);
  }

  // ======== HAPUS KERANJANG METHODS ========
  Future<void> _hapusKeSupabase(Kopi kopi, String ukuran) async {
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
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _bersihkanItemDipilihDariSupabase() async {
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
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _bersihkanKeranjangDariSupabase() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _supabase.from('keranjang').delete().eq('id_user', currentUser.id);

      _errorMessage = null;
      await fetchKeranjangItems();
    } catch (e) {
      _errorMessage = "Gagal membersihkan keranjang: ${e.toString()}";
      print("[KeranjangController] Error bersihkanKeranjangDariSupabase: $e");
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void hapus(Kopi kopi, String ukuran) {
    _hapusKeSupabase(kopi, ukuran);
  }

  void bersihkanItemDipilih() {
    _bersihkanItemDipilihDariSupabase();
  }

  void bersihkanKeranjang() {
    _bersihkanKeranjangDariSupabase();
  }

  // ======== EDIT KERANJANG METHODS ========
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

  Future<void> _ubahJumlahDiSupabase(
    Kopi kopi,
    String ukuran,
    int delta,
  ) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    // Update lokal terlebih dahulu untuk responsivitas UI
    final itemIndex = _keranjang.indexWhere(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );

    if (itemIndex != -1) {
      final currentItem = _keranjang[itemIndex];
      final newJumlah = currentItem.jumlah + delta;

      if (newJumlah <= 0) {
        // Hapus item dari lokal
        _keranjang.removeAt(itemIndex);
      } else {
        // Update jumlah di lokal
        currentItem.jumlah = newJumlah;
      }
      notifyListeners(); // Update UI immediately
    }

    // Kemudian update ke Supabase
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
    } catch (e) {
      _errorMessage = "Gagal mengubah jumlah: ${e.toString()}";
      print("[KeranjangController] Error ubahJumlahDiSupabase: $e");
      // Rollback jika terjadi error - fetch ulang dari server
      await fetchKeranjangItems();
    }
  }

  void ubahJumlah(Kopi kopi, String ukuran, int delta) {
    _ubahJumlahDiSupabase(kopi, ukuran, delta);
  }

  // ======== PILIH KERANJANG METHODS ========
  Future<void> _togglePilihDiSupabase(Kopi kopi, String ukuran) async {
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
      } catch (e) {
        // Rollback jika gagal
        itemToToggle.dipilih = !newStatusDipilih;
        _errorMessage = "Gagal mengubah status pilihan: ${e.toString()}";
        print("[KeranjangController] Error togglePilihDiSupabase: $e");
        notifyListeners();
      }
    }
  }

  Future<void> _pilihSemuaDiSupabase(bool value) async {
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

  void togglePilih(Kopi kopi, String ukuran) {
    _togglePilihDiSupabase(kopi, ukuran);
  }

  void pilihSemua(bool value) {
    _pilihSemuaDiSupabase(value);
  }

  // ======== CEK KERANJANG METHODS ========
  bool sudahAda(Kopi kopi, String ukuran) {
    return _keranjang.any(
      (item) => item.kopi.id == kopi.id && item.ukuran == ukuran,
    );
  }

  int get totalItemDiKeranjang {
    int total = 0;
    for (var item in _keranjang) {
      total += item.jumlah;
    }
    return total;
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

  bool get semuaDipilih {
    return _keranjang.isNotEmpty && _keranjang.every((item) => item.dipilih);
  }

  // ======== FETCH KERANJANG METHODS ========
  Future<void> fetchKeranjangItems() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      if (_keranjang.isNotEmpty || _isLoading || _errorMessage != null) {
        clearLocalCartAndResetState();
      }
      print(
        '[KeranjangController] No user logged in. Cart state reset by fetch.',
      );
      return;
    }

    bool needsToNotifyLoading = false;
    if (!_isLoading) {
      _isLoading = true;
      needsToNotifyLoading = true;
    }

    _errorMessage = null;

    if (needsToNotifyLoading) {
      notifyListeners();
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
            created_at,
            kopi:id_kopi (id, nama_kopi, harga, gambar, komposisi, deskripsi, stok) 
          ''')
          .eq('id_user', currentUser.id)
          .order(
            'created_at',
            ascending: true,
          ); // Urutkan berdasarkan created_at

      if (response is List) {
        final keranjangItems =
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
                  );
                })
                .whereType<KeranjangItem>()
                .toList();

        // Pisahkan item berdasarkan stok
        _keranjang =
            keranjangItems.where((item) => item.kopi.stok > 0).toList();
        _keranjangHabis =
            keranjangItems.where((item) => item.kopi.stok <= 0).toList();

        _errorMessage = null;     

        print(
          '[KeranjangController] Keranjang berhasil di-fetch. Item tersedia: ${_keranjang.length}, Item habis: ${_keranjangHabis.length}',
        );
      } else {
        _keranjang = [];
        _keranjangHabis = [];
        _errorMessage = "Format data keranjang tidak valid dari server.";
        print(
          '[KeranjangController] Unexpected response format for keranjang items: $response',
        );
      }
    } catch (e) {
      _errorMessage = "Gagal memuat keranjang: ${e.toString()}";
      print('[KeranjangController] Error fetching keranjang from Supabase: $e');
      _keranjang = [];
      _keranjangHabis = [];
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      } else if (needsToNotifyLoading == false &&
          (_keranjang.isNotEmpty ||
              _keranjangHabis.isNotEmpty ||
              _errorMessage != null)) {
        notifyListeners();
      }
    }
  }
}
