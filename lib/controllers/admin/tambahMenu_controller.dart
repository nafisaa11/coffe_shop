// lib/controllers/tambah_menu_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/services/uploadGambar_service.dart'; // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahMenuController with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final namaKopiController = TextEditingController();
  final gambarStatusController = TextEditingController(); // Untuk menampilkan status gambar/URL
  final komposisiController = TextEditingController();
  final deskripsiController = TextEditingController();
  final hargaController = TextEditingController();

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final String supabaseBucketName = 'kopiku'; // Nama bucket Anda

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
      // Ambil nama file saja dari path lengkap
      String fileName = file.path.split('/').last;
      if (fileName.length > 30) { // Pangkas jika terlalu panjang
          fileName = "...${fileName.substring(fileName.length - 27)}";
      }
      gambarStatusController.text = 'Terpilih: $fileName';
    } else {
      gambarStatusController.clear();
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
      _showSnackBar(context, 'Error memilih gambar: ${e.toString()}', isError: true);
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    namaKopiController.clear();
    komposisiController.clear();
    deskripsiController.clear();
    hargaController.clear();
    _setSelectedImageFile(null); // Ini juga akan mengosongkan gambarStatusController
    _setErrorMessage(null);
    // Tidak perlu notifyListeners() secara eksplisit jika _setSelectedImageFile dan _setErrorMessage sudah melakukannya
  }

  Future<void> tambahMenu(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImageFile == null) {
      _showSnackBar(context, '⚠️ Silakan pilih gambar terlebih dahulu.', isError: true);
      return;
    }

    _setLoading(true);
    _setErrorMessage(null);

    try {
      final String? imageUrl = await uploadImageToSupabase(
        _selectedImageFile!,
        supabaseBucketName,
      );

      if (imageUrl == null) {
        throw Exception('Gagal mengupload gambar. Periksa koneksi dan konfigurasi bucket ($supabaseBucketName).');
      }
      
      // Update status controller dengan URL setelah upload berhasil
      gambarStatusController.text = 'URL: Terupload!'; // Atau tampilkan sebagian URL jika mau
      notifyListeners();


      final hargaString = hargaController.text.replaceAll('.', '').replaceAll(',', '');
      final hargaInt = int.parse(hargaString);

      await Supabase.instance.client.from('kopi').insert({
        'nama_kopi': namaKopiController.text.trim(),
        'gambar': imageUrl,
        'komposisi': komposisiController.text.trim(),
        'deskripsi': deskripsiController.text.trim(),
        'harga': hargaInt,
      }).select(); // .select() bisa digunakan jika Anda ingin mendapatkan data yang baru saja diinsert

      _showSuccessDialog(context, imageUrl, namaKopiController.text.trim());
      resetForm(); // Reset form setelah dialog sukses
      // _showSnackBar(context, '✅ Menu "${namaKopiController.text.trim()}" berhasil ditambahkan!', isError: false); // Snackbar bisa jadi redundant dengan dialog

    } catch (error) {
      print('Error saat tambah menu: $error');
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

  void _showSuccessDialog(BuildContext context, String imageUrl, String menuName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              const Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menu "$menuName" telah ditambahkan.'),
              const SizedBox(height: 15),
              const Text('Preview Gambar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (ctx, err, stack) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              const SizedBox(height: 8),
                              Text("Gagal memuat preview", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              SelectableText(
                imageUrl,
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
                maxLines: 3,
                minLines: 1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.hideCurrentSnackBar(); // Sembunyikan snackbar sebelumnya jika ada
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: isError ? Colors.redAccent : Colors.brown[600],
          behavior: SnackBarBehavior.floating, // Opsi: floating atau fixed
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10), // Hanya jika behavior floating
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