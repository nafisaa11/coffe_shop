// lib/pages/admin/edit_menu_page.dart (atau path yang sesuai)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopiqu/controllers/admin/editMenu_controller.dart';
import 'package:kopiqu/models/kopi.dart'; // Model Kopi
import 'package:kopiqu/widgets/Format/titikOtomatis_widget.dart'; // Formatter harga

class EditMenuPage extends StatefulWidget {
  final Kopi kopi; // Data kopi yang akan diedit

  const EditMenuPage({super.key, required this.kopi});

  @override
  State<EditMenuPage> createState() => _EditMenuPageState();
}

class _EditMenuPageState extends State<EditMenuPage> {
  late EditMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditMenuController(kopiToEdit: widget.kopi);
    _controller.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild UI saat controller berubah
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Helper InputDecoration (sama seperti di TambahMenuPage)
  InputDecoration _styledInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixTextString,
  }) {
    final hintStyle = TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5));
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixText: prefixTextString,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildImagePreview() {
    // Prioritaskan gambar baru yang dipilih
    if (_controller.selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: Image.file(
          _controller.selectedImageFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder('Gagal memuat preview gambar baru'),
        ),
      );
    } 
    // Jika tidak ada gambar baru, tampilkan gambar awal dari URL
    else if (_controller.initialImageUrl != null && _controller.initialImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.5),
        child: Image.network(
          _controller.initialImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
          errorBuilder: (context, error, stackTrace) => _imageErrorPlaceholder('Gagal memuat gambar dari URL'),
        ),
      );
    } 
    // Jika tidak ada keduanya, tampilkan placeholder
    else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey[500]),
            const SizedBox(height: 10),
            Text('Tidak ada gambar', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }
  }

  Widget _imageErrorPlaceholder(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.red[700])),
          ],
        ),
      ),
    );
  }
  
  // Helper untuk padding dinamis ikon prefix pada TextFormField multiline
  // Ini adalah pendekatan dasar, mungkin perlu penyesuaian lebih lanjut
  double _calculatePrefixIconPadding(int currentLines, int maxLines) {
    if (maxLines <= 1) return 0.0;
    // Perkiraan padding berdasarkan jumlah baris
    // Anda mungkin perlu menyesuaikan angka ini berdasarkan font dan line height Anda
    double basePaddingPerLine = 22.0; // Sesuaikan nilai ini
    double totalFieldHeightFactor = (maxLines - 1) * basePaddingPerLine;
    double currentTextHeightFactor = (currentLines - 1) * basePaddingPerLine;
    return (totalFieldHeightFactor - currentTextHeightFactor) / 2 + (currentTextHeightFactor/2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Edit Menu: ${widget.kopi.nama_kopi}'),
        backgroundColor: Colors.brown[700], // Warna berbeda untuk Edit
        foregroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Preview Gambar
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: GestureDetector(
                  onTap: _controller.isLoading ? null : () => _controller.pickImage(context),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _buildImagePreview(), // Menggunakan helper untuk preview
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Status Gambar & Tombol Pilih Gambar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _controller.gambarStatusController,
                      readOnly: true,
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, fontStyle: FontStyle.italic),
                      decoration: _styledInputDecoration(
                        labelText: 'Status/URL Gambar',
                        hintText: 'URL atau status gambar',
                        prefixIcon: Icon(Icons.image_outlined, color: Colors.grey[600]),
                      ).copyWith(
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _controller.isLoading ? null : () => _controller.pickImage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[600], // Warna tombol edit gambar
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2.0,
                        ),
                        child: const Icon(Icons.photo_camera_back_outlined, size: 22), // Ikon ganti gambar
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Field Nama Kopi
              TextFormField(
                controller: _controller.namaKopiController,
                decoration: _styledInputDecoration(
                  labelText: 'Nama Kopi',
                  hintText: 'Cth: Kopi Tubruk Mantap',
                  prefixIcon: Icon(Icons.coffee_maker_outlined, color: Colors.brown[700]),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama kopi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Field Komposisi
              TextFormField(
                controller: _controller.komposisiController,
                maxLines: 2,
                onChanged: (_) => setState((){}), // Untuk update padding prefix icon jika perlu
                decoration: _styledInputDecoration(
                  labelText: 'Komposisi',
                  hintText: 'Cth: Biji kopi Robusta, Air panas',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: _calculatePrefixIconPadding(
                        _controller.komposisiController.text.split('\n').length, 2)),
                    child: Icon(Icons.format_list_bulleted_rounded, color: Colors.brown[700]),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komposisi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Field Deskripsi
              TextFormField(
                controller: _controller.deskripsiController,
                maxLines: 3,
                onChanged: (_) => setState((){}), // Untuk update padding prefix icon jika perlu
                decoration: _styledInputDecoration(
                  labelText: 'Deskripsi Menu',
                  hintText: 'Deskripsikan rasa dan keunikan kopi...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: _calculatePrefixIconPadding(
                        _controller.deskripsiController.text.split('\n').length, 3)),
                    child: Icon(Icons.description_outlined, color: Colors.brown[700]),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Field Harga
              TextFormField(
                controller: _controller.hargaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: _styledInputDecoration(
                  labelText: 'Harga Kopi',
                  hintText: 'Cth: 10.000',
                  prefixIcon: Icon(Icons.payments_outlined, color: Colors.brown[700]),
                  prefixTextString: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                  final harga = int.tryParse(cleaned);
                  if (harga == null) {
                    return 'Format harga tidak valid';
                  }
                  if (harga <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),

              // Tombol Simpan Perubahan
              ElevatedButton.icon(
                icon: _controller.isLoading 
                    ? Container(
                        width: 22, height: 22, 
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      ) 
                    : const Icon(Icons.save_as_outlined, size: 20),
                label: Text(_controller.isLoading ? 'MENYIMPAN...' : 'Simpan Perubahan', style: const TextStyle(fontSize: 17)),
                onPressed: _controller.isLoading ? null : () => _controller.saveChanges(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600], // Warna tombol simpan
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 3.0,
                ),
              ),

              // Error Message
              if (_controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    // Sama seperti di TambahMenuPage
                     padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50]?.withOpacity(0.8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.7)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _controller.errorMessage!,
                            style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}