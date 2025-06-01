// screens/edit_profile_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/Profile/bottomContentEditProfile_widget.dart';
import 'package:kopiqu/widgets/Profile/buttonEditProfile_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedImageFile;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final AuthService _authService = AuthService();
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          _showSuccessSnackBar('Password berhasil diubah!');
        }
      }

      if (mounted) {
        _showSuccessSnackBar('Profil berhasil diperbarui!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print("Error saat menyimpan profil: $e");
      if (mounted) {
        _showErrorSnackBar('Gagal menyimpan profil: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced Header with gradient and better spacing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFD07C3D),
                      const Color(0xFFD07C3D).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    // Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const SizedBox(width: 32),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: Icon(
                            PhosphorIcons.x(PhosphorIconsStyle.bold),
                            color: Colors.white.withOpacity(0),
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                        const Text(
                          'Ubah Profil',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: Icon(
                            PhosphorIcons.x(PhosphorIconsStyle.bold),
                            color: Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perbarui informasi akun Anda',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Content with better spacing and styling
              BottomContentProfile(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                currentPhotoUrl: _currentPhotoUrl,
                onImageSelected: _handleImageSelected,
              ),

              // Enhanced Action Buttons
              ButtonEditProfile(
                isLoading: _isLoading,
                onCancel: () => Navigator.of(context).pop(false),
                onSave: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
