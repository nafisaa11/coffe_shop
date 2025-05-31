// screens/edit_profile_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/ProfilePhotoPicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/customtextfield.dart';

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
      _emailController.text = user.email ?? '';
      _nameController.text = user.userMetadata?['display_name'] ?? '';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan warna accent
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD07C3D),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_outline, size: 32, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbarui informasi akun Anda',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Photo dengan styling yang lebih clean
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(0xFFD07C3D),
                              width: 1,
                            ),
                          ),
                          child: ProfilePhotoPicker(
                            initialImageUrl: _currentPhotoUrl,
                            initialAssetPath: 'assets/fotoprofile.jpg',
                            onImageSelected: _handleImageSelected,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Form Fields dengan spacing yang konsisten
                        CustomTextField(
                          label: 'Nama Lengkap',
                          hintText: 'Masukkan nama lengkap Anda',
                          controller: _nameController,
                          isPasswordTextField: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Email',
                          hintText: 'Email tidak dapat diubah',
                          controller: _emailController,
                          readOnly: true,
                          isPasswordTextField: false,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: 'Password Baru',
                          hintText: 'Kosongkan jika tidak ingin mengubah',
                          controller: _passwordController,
                          obscureTextInitially: true,
                          isPasswordTextField: true,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons dengan desain yang lebih modern
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isLoading
                                ? Colors.grey.shade400
                                : Color(0xFFD07C3D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Menyimpan...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                              : const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
