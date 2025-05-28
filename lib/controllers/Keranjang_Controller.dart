import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';

class KeranjangController extends ChangeNotifier {
  final List<Map<String, dynamic>> _keranjang = [];

  bool sudahAda(Kopi kopi, String ukuran) {
    return _keranjang.any(
      (item) => item['kopi'] == kopi && item['ukuran'] == ukuran,
    );
  }

  List<Map<String, dynamic>> get keranjang => _keranjang;

  void ubahUkuran(Kopi kopi, String oldUkuran, String newUkuran) {
    final index = _keranjang.indexWhere(
      (item) => item['kopi'] == kopi && item['ukuran'] == oldUkuran,
    );

    if (index != -1) {
      final item = _keranjang[index];

      // Cek apakah kombinasi baru sudah ada
      final newIndex = _keranjang.indexWhere(
        (item) => item['kopi'] == kopi && item['ukuran'] == newUkuran,
      );

      if (newIndex != -1) {
        // Kalau sudah ada, tambahkan jumlahnya ke item yang sudah ada
        _keranjang[newIndex]['jumlah'] += item['jumlah'];
        _keranjang.removeAt(index);
      } else {
        // Kalau belum ada, ubah ukuran
        item['ukuran'] = newUkuran;
      }

      notifyListeners();
    }
  }

  void tambah(Kopi kopi, String ukuran) {
    final index = _keranjang.indexWhere(
      (item) => item['kopi'] == kopi && item['ukuran'] == ukuran,
    );

    if (index == -1) {
      _keranjang.add({
        'kopi': kopi,
        'ukuran': ukuran,
        'jumlah': 1,
        'dipilih': true,
      });
    } else {
      _keranjang[index]['jumlah'] += 1;
    }

    notifyListeners();
  }

  void hapus(Kopi kopi, String ukuran) {
    _keranjang.removeWhere(
      (item) => item['kopi'] == kopi && item['ukuran'] == ukuran,
    );
    notifyListeners();
  }

  void ubahJumlah(Kopi kopi, String ukuran, int delta) {
    final index = _keranjang.indexWhere(
      (item) => item['kopi'] == kopi && item['ukuran'] == ukuran,
    );

    if (index != -1) {
      _keranjang[index]['jumlah'] += delta;
      if (_keranjang[index]['jumlah'] <= 0) {
        _keranjang.removeAt(index);
      }
      notifyListeners();
    }
  }

  void togglePilih(Kopi kopi, String ukuran) {
    final index = _keranjang.indexWhere(
      (item) => item['kopi'] == kopi && item['ukuran'] == ukuran,
    );

    if (index != -1) {
      _keranjang[index]['dipilih'] = !_keranjang[index]['dipilih'];
      notifyListeners();
    }
  }

  void pilihSemua(bool value) {
    for (var item in _keranjang) {
      item['dipilih'] = value;
    }
    notifyListeners();
  }

  int get totalHarga {
    return _keranjang
        .where((item) => item['dipilih'])
        .fold(
          0,
          (total, item) => total + (item['kopi'].harga * item['jumlah']) as int,
        );
  }

  // Method untuk membersihkan keranjang setelah transaksi selesai
  void bersihkanKeranjang() {
    _keranjang.clear();
    notifyListeners();
  }

  // Method untuk membersihkan hanya item yang dipilih
  void bersihkanItemDipilih() {
    _keranjang.removeWhere((item) => item['dipilih'] == true);
    notifyListeners();
  }

  // Method untuk mendapatkan item yang dipilih saja
  List<Map<String, dynamic>> get itemDipilih {
    return _keranjang.where((item) => item['dipilih'] == true).toList();
  }

  // Method untuk menghitung total item yang dipilih
  int get totalItemDipilih {
    int total = 0;
    for (var item in _keranjang) {
      if (item['dipilih'] == true) {
        total += item['jumlah'] as int;
      }
    }
    return total;
  }

  bool get semuaDipilih => _keranjang.every((item) => item['dipilih']);
}


