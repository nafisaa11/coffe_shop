import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kopiqu/controllers/admin/tambahMenu_controller.dart';
import 'package:kopiqu/widgets/Format/titikOtomatis_widget.dart'; // Pastikan widget ini ada

class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  late TambahMenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TambahMenuController();
    _controller.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild UI ketika controller memanggil notifyListeners()
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Helper untuk InputDecoration agar konsisten
  InputDecoration _styledInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefixTextString, // Untuk prefix seperti 'Rp '
  }) {
    final hintStyle = TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5));
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixText: prefixTextString,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Border radius lebih besar
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder( // Border saat tidak error dan aktif
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder( // Border saat fokus
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0), // Sesuaikan padding
      filled: true,
      fillColor: Colors.white, // Warna latar field
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang page
      appBar: AppBar(
        title: Center(child: const Text('Tambah Menu Baru')),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0), // Padding bawah lebih besar
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
                      color: Colors.white, // Ubah warna latar
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _controller.selectedImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.5),
                            child: Image.file(
                              _controller.selectedImageFile!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('Gagal memuat preview', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 60, color: Colors.grey[500]),
                                const SizedBox(height: 10),
                                Text('Ketuk untuk memilih gambar', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Status Gambar & Tombol Pilih Gambar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to start
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _controller.gambarStatusController,
                      readOnly: true,
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, fontStyle: FontStyle.italic),
                      decoration: _styledInputDecoration(
                        labelText: 'Status Gambar',
                        hintText: 'Belum ada gambar dipilih',
                        prefixIcon: Icon(Icons.image_outlined, color: Colors.brown[700]),
                      ).copyWith(
                        fillColor: Colors.grey[50], // Warna field status lebih pudar
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50.0, // Sesuaikan tinggi tombol
                      child: ElevatedButton(
                        onPressed: _controller.isLoading ? null : () => _controller.pickImage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2.0,
                        ),
                        child: const Icon(Icons.upload_file_rounded, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Nama Kopi
              TextFormField(
                controller: _controller.namaKopiController,
                decoration: _styledInputDecoration(
                  labelText: 'Nama Kopi',
                  hintText: 'Cth: Kopi Susu Gula Aren',
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

              // Komposisi
              TextFormField(
                controller: _controller.komposisiController,
                maxLines: 2,
                decoration: _styledInputDecoration(
                  labelText: 'Komposisi',
                  hintText: 'Cth: Kopi, Susu, Gula Aren',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 25.0), // Adjust alignment
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

              // Deskripsi
              TextFormField(
                controller: _controller.deskripsiController,
                maxLines: 3,
                decoration: _styledInputDecoration(
                  labelText: 'Deskripsi Kopi',
                  hintText: 'Jelaskan keunikan menu kopi ini...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48.0), // Adjust alignment
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

              // Harga
              TextFormField(
                controller: _controller.hargaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(), // Widget format harga Anda
                ],
                decoration: _styledInputDecoration(
                  labelText: 'Harga Kopi',
                  hintText: 'Cth: 15.000',
                  prefixIcon: Icon(Icons.payments_outlined, color: Colors.brown[700]),
                  prefixTextString: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final cleaned = value.replaceAll('.', '').replaceAll(',', '');
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

              // Tombol Tambah Menu
              ElevatedButton.icon(
                icon: _controller.isLoading 
                    ? Container(
                        width: 22, height: 22, 
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      ) 
                    : const Icon(Icons.add, size: 20),
                label: Text(_controller.isLoading ? 'MEMPROSES...' : 'Tambah Menu', style: const TextStyle(fontSize: 17)),
                onPressed: _controller.isLoading ? null : () => _controller.tambahMenu(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
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