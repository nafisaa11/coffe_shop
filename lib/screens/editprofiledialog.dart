// screens/edit_profile_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/ProfilePhotoPicker.dart'; // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/services/auth_service.dart'; // Pastikan path ini benar

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey =
      GlobalKey<FormState>(); // 👈 1. Tambahkan GlobalKey untuk Form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // Email tetap read-only
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImageFile; // Menyimpan File gambar yang dipilih
  String? _currentPhotoUrl; // Menyimpan URL foto profil saat ini (jika ada)

  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // Instance AuthService
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _nameController.text = user.userMetadata?['display_name'] ?? '';
        _currentPhotoUrl =
            user.userMetadata?['photo_url']
                as String?; // Ambil URL foto saat ini
      });
    }
  }

  void _handleImageSelected(File? image) {
    // Callback dari ProfilePhotoPicker
    setState(() {
      _selectedImageFile = image;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      // 👈 2. Validasi Form
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    String? newPhotoUrl;

    try {
      // 3. Upload foto profil baru jika ada perubahan
      if (_selectedImageFile != null) {
        print('Mengupload foto profil baru...');
        newPhotoUrl = await _authService.uploadProfilePhoto(
          _supabase.auth.currentUser!.id,
          _selectedImageFile!,
        );
        print('Foto profil baru diupload ke: $newPhotoUrl');
      }

      // 4. Update display name
      // (AuthService.updateDisplayName Anda sudah ada, pastikan ia menghandle userMetadata)
      // Jika updateDisplayName hanya mengupdate metadata dan tidak password/email:
      bool displayNameUpdated = false;
      if (_nameController.text !=
          (_supabase.auth.currentUser?.userMetadata?['display_name'] ?? '')) {
        await _authService.updateUserMetadata(
          displayName: _nameController.text,
          photoUrl:
              newPhotoUrl, // Kirim URL foto baru (atau null jika tidak berubah)
        );
        displayNameUpdated = true;
        print('Display name dan/atau foto URL diupdate di metadata.');
      } else if (newPhotoUrl != null) {
        // Jika hanya foto yang berubah, tetap update metadata
        await _authService.updateUserMetadata(photoUrl: newPhotoUrl);
        displayNameUpdated = true;
        print('Foto URL diupdate di metadata.');
      }

      // 5. Update password jika diisi
      if (_passwordController.text.isNotEmpty) {
        print('Mengupdate password...');
        await _supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
        print('Password berhasil diupdate.');
        // Opsional: Beri tahu pengguna untuk login ulang jika password diubah
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Password berhasil diubah. Anda mungkin perlu login ulang nanti.',
              ),
            ),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(true); // Kirim 'true' untuk menandakan ada perubahan
      }
    } catch (e) {
      print("Error saat menyimpan profil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Profil',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(20.0),
      content: SingleChildScrollView(
        child: Form(
          // 👈 6. Bungkus dengan Form
          key: _formKey, // Gunakan GlobalKey
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfilePhotoPicker(
                // Berikan URL foto profil saat ini jika ada, atau path aset default
                initialImageUrl:
                    _currentPhotoUrl, // Gunakan URL dari user metadata
                initialAssetPath:
                    'assets/foto.jpg', // Fallback jika URL tidak ada
                onImageSelected: _handleImageSelected,
              ),
              const SizedBox(height: 20),
              TextFormField(
                // 👈 7. Ganti TextField menjadi TextFormField
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true, // Email tidak bisa diubah
                decoration: const InputDecoration(
                  labelText: 'Email (Tidak bisa diubah)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Color.fromARGB(255, 232, 232, 232),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText:
                      'Password Baru (Kosongkan jika tidak ingin diubah)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  // Password bisa kosong (artinya tidak ingin diubah)
                  // Tapi jika diisi, harus memenuhi kriteria tertentu (misal panjang minimal)
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isLoading
                  ? null
                  : () => Navigator.of(
                    context,
                  ).pop(false), // Kirim 'false' jika batal
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          icon:
              _isLoading
                  ? Container(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save_outlined, size: 18),
          label: _isLoading ? const Text('Menyimpan...') : const Text('Simpan'),
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Theme.of(context).primaryColor, // Gunakan warna tema
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
