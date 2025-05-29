// services/cart_ui_service.dart
import 'package:flutter/material.dart';

class CartUIService extends ChangeNotifier {
  GlobalKey? _cartIconKey; // Kunci Global untuk ikon keranjang
  Offset? _cartIconPosition; // Posisi ikon keranjang

  GlobalKey? get cartIconKey => _cartIconKey;
  Offset? get cartIconPosition => _cartIconPosition;

  // Dipanggil dari widget ikon keranjang untuk mendaftarkan GlobalKey-nya
  void registerCartIconKey(GlobalKey key) {
    _cartIconKey = key;
    // Kita bisa langsung menghitung posisinya di sini jika widget sudah di-render
    // atau biarkan halaman menu yang menghitungnya saat animasi akan dimulai.
    // Untuk sekarang, kita hanya simpan key-nya.
    // notifyListeners(); // Tidak perlu notify untuk ini, hanya penyimpanan referensi
  }

  // Dipanggil untuk mengupdate posisi (jika diperlukan)
  void updateCartIconPosition() {
    if (_cartIconKey?.currentContext != null) {
      final RenderBox renderBox =
          _cartIconKey!.currentContext!.findRenderObject() as RenderBox;
      _cartIconPosition =
          renderBox.localToGlobal(Offset.zero) +
          Offset(renderBox.size.width / 2, renderBox.size.height / 2);
      // notifyListeners(); // Mungkin tidak perlu notify, tergantung bagaimana ini digunakan
    }
  }
}
