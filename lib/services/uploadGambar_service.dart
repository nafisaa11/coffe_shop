// services/uploadGambar_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Memilih gambar dari galeri pengguna.
/// Mengembalikan objek File jika gambar dipilih, jika tidak null.
Future<File?> pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Batas maksimal lebar gambar
      maxHeight: 1024, // Batas maksimal tinggi gambar
      imageQuality: 85, // Kualitas gambar (0-100)
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } catch (e) {
    print('Error picking image: $e');
    throw Exception('Gagal memilih gambar: $e');
  }
}

/// Mengunggah file gambar yang diberikan ke Supabase Storage dan mengembalikan URL publiknya.
///
/// [imageFile]: File gambar yang akan diunggah.
/// [bucketName]: Nama bucket Supabase Storage Anda (misalnya, 'kopiqu').
/// Mengembalikan URL publik dari gambar yang diunggah, atau null jika terjadi kegagalan.
Future<String?> uploadImageToSupabase(File imageFile, String bucketName) async {
  try {
    // Validasi file
    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan');
    }

    // Periksa ukuran file (maksimal 5MB)
    final fileSize = await imageFile.length();
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (fileSize > maxSize) {
      throw Exception('Ukuran file terlalu besar (maksimal 5MB)');
    }

    // Generate nama file unik
    final String fileExtension = path.extension(imageFile.path).toLowerCase();
    final String fileName = '${const Uuid().v4()}$fileExtension';
    final String filePath = 'menu-images/$fileName'; // Folder untuk gambar menu

    // Upload file ke Supabase Storage
    final uploadResponse = await Supabase.instance.client.storage
        .from(bucketName)
        .upload(filePath, imageFile);

    // Dapatkan URL publik
    final String publicUrl = Supabase.instance.client.storage
        .from(bucketName)
        .getPublicUrl(filePath);

    print('Upload berhasil: $publicUrl');
    return publicUrl;
    
  } on StorageException catch (e) {
    print('Supabase Storage Error: ${e.message}');
    
    // Handle error spesifik
    if (e.message.contains('Duplicate')) {
      throw Exception('File dengan nama yang sama sudah ada');
    } else if (e.message.contains('Policy')) {
      throw Exception('Tidak ada izin untuk mengupload file');
    } else if (e.message.contains('Bucket')) {
      throw Exception('Bucket storage tidak ditemukan');
    } else {
      throw Exception('Error upload: ${e.message}');
    }
  } catch (e) {
    print('Error uploading image to Supabase: $e');
    throw Exception('Gagal mengupload gambar: $e');
  }
}

/// Menghapus gambar dari Supabase Storage berdasarkan URL
/// [imageUrl]: URL gambar yang akan dihapus
/// [bucketName]: Nama bucket Supabase Storage
Future<bool> deleteImageFromSupabase(String imageUrl, String bucketName) async {
  try {
    // Extract file path from URL
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    
    // Cari index 'object' dalam path
    final objectIndex = pathSegments.indexOf('object');
    if (objectIndex == -1 || objectIndex >= pathSegments.length - 1) {
      throw Exception('URL gambar tidak valid');
    }
    
    // Ambil path file setelah 'object/{bucketName}/'
    final filePath = pathSegments.sublist(objectIndex + 2).join('/');
    
    // Hapus file dari storage
    await Supabase.instance.client.storage
        .from(bucketName)
        .remove([filePath]);
    
    print('Gambar berhasil dihapus: $filePath');
    return true;
  } catch (e) {
    print('Error deleting image: $e');
    return false;
  }
}

/// Model class untuk data Kopi
class Kopi {
  final int id;
  final String gambar;
  final String nama_kopi;
  final String komposisi;
  final String deskripsi;
  final int harga;
  final DateTime? created_at;

  Kopi({
    required this.id,
    required this.gambar,
    required this.nama_kopi,
    required this.komposisi,
    required this.deskripsi,
    required this.harga,
    this.created_at,
  });

  factory Kopi.fromMap(Map<String, dynamic> map) {
    return Kopi(
      id: map['id'] ?? 0,
      gambar: map['gambar'] ?? '',
      nama_kopi: map['nama_kopi'] ?? 'Tidak ada nama',
      komposisi: map['komposisi'] ?? 'Tidak ada komposisi',
      deskripsi: map['deskripsi'] ?? 'Tidak ada deskripsi',
      harga: map['harga'] ?? 0,
      created_at: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gambar': gambar,
      'nama_kopi': nama_kopi,
      'komposisi': komposisi,
      'deskripsi': deskripsi,
      'harga': harga,
      'created_at': created_at?.toIso8601String(),
    };
  }

  static List<Kopi> listFromJson(List<dynamic> data) {
    return data.map((item) => Kopi.fromMap(item)).toList();
  }

  @override
  String toString() {
    return 'Kopi(id: $id, nama_kopi: $nama_kopi, harga: $harga)';
  }
}