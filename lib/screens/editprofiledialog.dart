import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/ProfilePhotoPicker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/services/auth_service.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImage;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _emailController.text = user?.email ?? '';
    _nameController.text = user?.userMetadata?['display_name'] ?? '';
  }

  void _handleImageSelected(File? image) {
    _selectedImage = image;
  }

  void _saveProfile() {
    // Panggil service AuthService untuk update email, display name, atau password kalau diisi
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profil'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ProfilePhotoPicker(
              initialImage: 'assets/foto.jpg',
              onImageSelected: _handleImageSelected,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),

        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () async {
                    setState(() => _isLoading = true);
                    try {
                      await AuthService().updateDisplayName(
                        _nameController.text,
                        context,
                      );

                      if (_passwordController.text.isNotEmpty) {
                        await Supabase.instance.client.auth.updateUser(
                          UserAttributes(password: _passwordController.text),
                        );
                      }

                      if (mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(true);
                      }
                    } catch (e) {
                      debugPrint("Update profile error: $e");
                      // tampilkan snackbar/toast jika perlu
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },

          child:
              _isLoading ? CircularProgressIndicator() : const Text('Simpan'),
        ),
      ],
    );
  }
}
