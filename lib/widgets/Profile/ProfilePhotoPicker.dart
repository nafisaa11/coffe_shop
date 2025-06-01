// widgets/ProfilePhotoPicker.dart (atau nama file Anda)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan package image_picker sudah ditambahkan di pubspec.yaml

class ProfilePhotoPicker extends StatefulWidget {
  // Mengganti initialImage menjadi initialImageUrl untuk kejelasan
  final String? initialImageUrl; // URL gambar dari network (Supabase Storage)
  final String
  initialAssetPath; // Path aset gambar default jika URL tidak ada atau gagal load
  final Function(File?) onImageSelected; // Callback saat gambar dipilih

  const ProfilePhotoPicker({
    super.key,
    this.initialImageUrl, // URL bisa null
    required this.initialAssetPath, // Path aset default wajib ada
    required this.onImageSelected,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _selectedImageFile; // File gambar yang baru dipilih oleh pengguna
  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker

  // Method untuk menampilkan pilihan sumber gambar (Galeri/Kamera)
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        // Membuat sudut atas melengkung
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.blueGrey,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop(); // Tutup bottom sheet
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.blueGrey,
                ),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop(); // Tutup bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method untuk mengambil gambar dari sumber yang dipilih
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth:
            800, // Batasi ukuran gambar untuk efisiensi penyimpanan dan upload
        maxHeight: 800,
        imageQuality: 85, // Kompresi kualitas gambar (0-100)
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() => _selectedImageFile = file);
        widget.onImageSelected(
          file,
        ); // Kirim file yang dipilih ke parent widget
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengambil gambar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider displayImageProvider;

    if (_selectedImageFile != null) {
      // 1. Jika ada gambar baru yang dipilih, gunakan itu
      displayImageProvider = FileImage(_selectedImageFile!);
    } else if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      // 2. Jika tidak, coba gunakan URL gambar awal (dari network)
      displayImageProvider = NetworkImage(widget.initialImageUrl!);
    } else {
      // 3. Jika tidak ada keduanya, gunakan gambar aset default
      displayImageProvider = AssetImage(widget.initialAssetPath);
    }

    return Stack(
      alignment: Alignment.center, // Pusatkan CircleAvatar utama
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor:
              Colors.grey.shade300, // Warna background jika gambar gagal load
          // Gunakan onBackgroundImageError untuk menangani error load NetworkImage
          // dan fallback ke AssetImage jika perlu
          onBackgroundImageError:
              (widget.initialImageUrl != null && _selectedImageFile == null)
                  ? (exception, stackTrace) {
                    print(
                      "Error loading network image: $exception. Falling back to asset.",
                    );
                    // Jika NetworkImage gagal, paksa rebuild dengan AssetImage
                    // Cara sederhana adalah dengan mengubah state yang memicu rebuild
                    // atau pastikan displayImageProvider di atas sudah handle ini dengan benar.
                    // Untuk lebih aman, kita bisa memanggil setState di sini jika displayImageProvider tidak otomatis update.
                    // Namun, logika penentuan displayImageProvider di atas seharusnya sudah cukup.
                    // Jika tidak, kita bisa lakukan:
                    // setState(() {
                    //   displayImageProvider = AssetImage(widget.initialAssetPath);
                    // });
                  }
                  : null,
          backgroundImage: displayImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0, // Posisikan ikon edit di kanan bawah avatar
          child: Material(
            // Tambahkan Material untuk efek ripple pada InkWell
            color:
                Theme.of(context).primaryColor, // Warna background tombol edit
            shape: const CircleBorder(),
            elevation: 2.0,
            child: InkWell(
              onTap:
                  () => _showImageSourceActionSheet(
                    context,
                  ), // Panggil method untuk menampilkan pilihan
              customBorder: const CircleBorder(),
              splashColor: Colors.white.withOpacity(0.3),
              child: Container(
                // Container tetap digunakan untuk padding dan bentuk
                padding: const EdgeInsets.all(8), // Padding untuk ikon
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
