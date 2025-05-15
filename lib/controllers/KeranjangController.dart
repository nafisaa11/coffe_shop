import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';

class KeranjangController extends ChangeNotifier {
  final List<Map<String, dynamic>> _keranjang = [];

  List<Map<String, dynamic>> get keranjang => _keranjang;

  void tambah(Kopi kopi) {
    final index = _keranjang.indexWhere((item) => item['kopi'].id == kopi.id);
    if (index != -1) {
      _keranjang[index]['jumlah'] += 1;
    } else {
      _keranjang.add({
        'kopi': kopi,
        'jumlah': 1,
        'dipilih': false,
      });
    }
    notifyListeners();
  }

  void hapus(Kopi kopi) {
    _keranjang.removeWhere((item) => item['kopi'].id == kopi.id);
    notifyListeners();
  }

  void ubahJumlah(Kopi kopi, int delta) {
    final index = _keranjang.indexWhere((item) => item['kopi'].id == kopi.id);
    if (index != -1) {
      final newJumlah = _keranjang[index]['jumlah'] + delta;
      if (newJumlah >= 1) {
        _keranjang[index]['jumlah'] = newJumlah;
        notifyListeners();
      }
    }
  }

  void togglePilih(Kopi kopi) {
    final index = _keranjang.indexWhere((item) => item['kopi'].id == kopi.id);
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
        .fold(0, (total, item) => total + (item['kopi'].harga * item['jumlah']) as int);
  }

  bool get semuaDipilih => _keranjang.every((item) => item['dipilih']);
}
