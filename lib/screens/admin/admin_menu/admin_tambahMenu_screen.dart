import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahMenuPage extends StatefulWidget {
  const TambahMenuPage({super.key});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaKopiController = TextEditingController();
  final TextEditingController _gambarController = TextEditingController();
  final TextEditingController _komposisiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _tambahMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await Supabase.instance.client.from('kopi').insert({
          'nama_kopi': _namaKopiController.text,
          'gambar': _gambarController.text.isEmpty ? null : _gambarController.text,
          'komposisi': _komposisiController.text,
          'deskripsi': _deskripsiController.text,
          'harga': int.tryParse(_hargaController.text) ?? 0,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu berhasil ditambahkan!')),
          );
          // Clear the form after successful submission
          _namaKopiController.clear();
          _gambarController.clear();
          _komposisiController.clear();
          _deskripsiController.clear();
          _hargaController.clear();
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan saat menambahkan menu: $error';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Menu Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _namaKopiController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kopi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kopi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _gambarController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Opsional)',
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan URL gambar kopi',
                ),
                // You might want to add a more robust image upload mechanism in a real application
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _komposisiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komposisi',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Biji kopi pilihan, susu segar, gula aren',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Komposisi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  hintText: 'Jelaskan tentang kopi ini',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Masukkan angka yang valid untuk harga';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _tambahMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Tambah Menu'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}