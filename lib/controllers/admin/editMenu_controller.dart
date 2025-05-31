// lib/controllers/admin/edit_menu_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart'; // Pastikan path model Kopi benar
import 'package:kopiqu/models/kopi.dart' as models;
import 'package:kopiqu/services/uploadGambar_service.dart'; // Path service upload
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Untuk formatting angka (harga)

class EditMenuController with ChangeNotifier {
  final models.Kopi kopiToEdit; // Data kopi yang akan diedit
  final formKey = GlobalKey<FormState>();

  late TextEditingController namaKopiController;
  late TextEditingController gambarStatusController; // Menampilkan URL/status gambar
  late TextEditingController komposisiController;
  late TextEditingController deskripsiController;
  late TextEditingController hargaController;

  File? _selectedImageFile; // File gambar baru yang dipilih
  File? get selectedImageFile => _selectedImageFile;

  String? _initialImageUrl; // URL gambar awal
  String? get initialImageUrl => _initialImageUrl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final String supabaseBucketName = 'kopiku'; // Sesuaikan nama bucket Anda

  EditMenuController({required this.kopiToEdit}) {
    // Inisialisasi semua controller dengan data dari kopiToEdit
    namaKopiController = TextEditingController(text: kopiToEdit.nama_kopi);
    
    _initialImageUrl = (kopiToEdit.gambar.isEmpty || kopiToEdit.gambar == 'Tidak ada gambar') 
                       ? null 
                       : kopiToEdit.gambar;
    gambarStatusController = TextEditingController(text: _formatImageUrlForDisplay(_initialImageUrl));

    komposisiController = TextEditingController(text: kopiToEdit.komposisi);
    deskripsiController = TextEditingController(text: kopiToEdit.deskripsi);

    // Format harga dengan pemisah ribuan untuk tampilan
    final formatter = NumberFormat.decimalPattern('id_ID');
    hargaController = TextEditingController(text: formatter.format(kopiToEdit.harga));
  }

  String _formatImageUrlForDisplay(String? url) {
    if (url == null || url.isEmpty) return 'Belum ada gambar';
    if (url.length > 40) return 'URL: ...${url.substring(url.length - 35)}';
    return 'URL: $url';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSelectedImageFile(File? file) {
    _selectedImageFile = file;
    if (file != null) {
      String fileName = file.path.split('/').last;
      if (fileName.length > 30) {
          fileName = "...${fileName.substring(fileName.length - 27)}";
      }
      gambarStatusController.text = 'Gambar Baru: $fileName';
    } else {
      // Jika pemilihan gambar baru dibatalkan, kembali ke URL awal
      gambarStatusController.text = _formatImageUrlForDisplay(_initialImageUrl);
    }
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final File? pickedImage = await pickImageFromGallery();
      if (pickedImage != null) {
        _setSelectedImageFile(pickedImage);
      }
    } catch (e) {
      _showSnackBar(context, 'Gagal memilih gambar: ${e.toString()}', isError: true);
    }
  }

  Future<void> saveChanges(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    String? finalImageUrl = _initialImageUrl; // Secara default gunakan URL gambar awal

    try {
      // Jika ada file gambar baru yang dipilih, upload dan gunakan URL baru
      if (_selectedImageFile != null) {
        final newImageUrl = await uploadImageToSupabase(
          _selectedImageFile!,
          supabaseBucketName,
        );
        if (newImageUrl == null) {
          throw Exception('Gagal mengupload gambar baru. Pastikan koneksi dan konfigurasi bucket ($supabaseBucketName) sudah benar.');
        }
        finalImageUrl = newImageUrl; // Gunakan URL gambar baru
        gambarStatusController.text = _formatImageUrlForDisplay(finalImageUrl); // Update status
        // Pertimbangkan untuk menghapus gambar lama dari Supabase Storage jika tidak lagi digunakan
        // (memerlukan implementasi tambahan untuk menghapus file berdasarkan URL atau path lama)
      }

      final hargaString = hargaController.text.replaceAll(RegExp(r'[^0-9]'), ''); // Hanya ambil digit
      final hargaInt = int.parse(hargaString);

      await Supabase.instance.client.from('kopi').update({
        'nama_kopi': namaKopiController.text.trim(),
        'gambar': (finalImageUrl?.isEmpty ?? true) ? null : finalImageUrl, // Simpan null jika URL kosong
        'komposisi': komposisiController.text.trim(),
        'deskripsi': deskripsiController.text.trim(),
        'harga': hargaInt,
      }).eq('id', kopiToEdit.id); // Pastikan model Kopi Anda memiliki field 'id'

      _showSnackBar(context, '✅ Menu "${namaKopiController.text.trim()}" berhasil diperbarui!', isError: false);
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true); // Kirim 'true' untuk menandakan sukses & memicu refresh jika perlu
      }

    } catch (error) {
      print('Error saat memperbarui menu: $error');
      String displayError = "Terjadi kesalahan: ${error.toString()}";
       if (error.toString().contains("Exception:")) {
          displayError = error.toString().replaceFirst("Exception: ", "");
      }
      if (error.toString().toLowerCase().contains("bucket not found")) {
          displayError = "Kesalahan: Bucket '$supabaseBucketName' tidak ditemukan di Supabase.";
      } else if (error.toString().toLowerCase().contains("network") || error.toString().toLowerCase().contains("socketexception")) {
          displayError = "Kesalahan jaringan: Periksa koneksi internet Anda.";
      }
      _setErrorMessage(displayError);
      _showSnackBar(context, '❌ $displayError', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: isError ? Colors.redAccent : Colors.brown[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  void dispose() {
    namaKopiController.dispose();
    gambarStatusController.dispose();
    komposisiController.dispose();
    deskripsiController.dispose();
    hargaController.dispose();
    super.dispose();
  }
}