// screens/edit_profile_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/ProfilePhotoPicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart'; // 👈 1. IMPORT CustomTextField

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImageFile;
  String? _currentPhotoUrl;
  // bool _obscurePassword = true; // Tidak perlu lagi, dihandle oleh CustomTextField
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Tidak perlu setState di sini karena controller akan langsung diisi
      _emailController.text = user.email ?? '';
      _nameController.text = user.userMetadata?['display_name'] ?? '';
      // Perlu setState jika _currentPhotoUrl digunakan untuk rebuild UI awal
      // Namun, ProfilePhotoPicker akan menangani initialImageUrl-nya sendiri.
      // Untuk konsistensi, jika ada perubahan pada _currentPhotoUrl, kita bisa setState.
      if (mounted) {
        setState(() {
          _currentPhotoUrl = user.userMetadata?['photo_url'] as String?;
        });
      }
    }
  }

  void _handleImageSelected(File? image) {
    setState(() {
      _selectedImageFile = image;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);

    String? newPhotoUrl;
    try {
      if (_selectedImageFile != null) {
        print('Mengupload foto profil baru...');
        newPhotoUrl = await _authService.uploadProfilePhoto(
          _supabase.auth.currentUser!.id,
          _selectedImageFile!,
        );
        print('Foto profil baru diupload ke: $newPhotoUrl');
      }

      bool metadataChanged = false;
      Map<String, dynamic> metadataToUpdate = {};

      if (_nameController.text !=
          (_supabase.auth.currentUser?.userMetadata?['display_name'] ?? '')) {
        metadataToUpdate['display_name'] = _nameController.text;
        metadataChanged = true;
      }
      if (newPhotoUrl != null) {
        // Jika ada foto baru yang diupload
        metadataToUpdate['photo_url'] = newPhotoUrl;
        metadataChanged = true;
      }

      if (metadataChanged) {
        await _authService.updateUserMetadata(
          displayName:
              metadataToUpdate.containsKey('display_name')
                  ? metadataToUpdate['display_name']
                  : null,
          photoUrl:
              metadataToUpdate.containsKey('photo_url')
                  ? metadataToUpdate['photo_url']
                  : null,
        );
        print('User metadata diupdate.');
      }

      if (_passwordController.text.isNotEmpty) {
        print('Mengupdate password...');
        await _supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
        print('Password berhasil diupdate.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password berhasil diubah.')),
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
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print("Error saat menyimpan profil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: ${e.toString()}'),
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
      contentPadding: const EdgeInsets.fromLTRB(
        20.0,
        20.0,
        20.0,
        0,
      ), // Kurangi padding bawah content
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfilePhotoPicker(
                initialImageUrl: _currentPhotoUrl,
                initialAssetPath: 'assets/foto.jpg',
                onImageSelected: _handleImageSelected,
              ),
              const SizedBox(height: 24), // Beri spasi lebih
              // 👇 2. GUNAKAN CustomTextField UNTUK NAMA
              CustomTextField(
                label: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap Anda',
                controller: _nameController,
                isPasswordTextField: false, // Bukan field password
                validator: (value) {
                  // Tambahkan validator jika perlu
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 👇 3. GUNAKAN CustomTextField UNTUK EMAIL (READ-ONLY)
              CustomTextField(
                label: 'Email (Tidak bisa diubah)',
                hintText:
                    '', // Hint text bisa dikosongkan jika label sudah jelas
                controller: _emailController,
                readOnly: true,
                isPasswordTextField: false,
              ),
              const SizedBox(height: 16),
              // 👇 4. GUNAKAN CustomTextField UNTUK PASSWORD BARU
              CustomTextField(
                label: 'Password Baru (Kosongkan jika tidak diubah)',
                hintText: 'Masukkan password baru',
                controller: _passwordController,
                obscureTextInitially: true, // Password disembunyikan awal
                isPasswordTextField: true, // Aktifkan fitur ikon mata
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Spasi sebelum tombol
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
        ),
        ElevatedButton.icon(
          icon:
              _isLoading
                  ? Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(right: 8),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save_outlined, size: 18),
          label: _isLoading ? const Text('Menyimpan...') : const Text('Simpan'),
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown.shade600, // Sesuaikan warna
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
