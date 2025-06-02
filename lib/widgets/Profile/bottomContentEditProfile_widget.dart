// widgets/bottomContentProfile_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/Profile/ProfilePhotoPicker.dart';
import 'package:kopiqu/widgets/Profile/textFieldEditProfile_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class BottomContentProfile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? currentPhotoUrl;
  final Function(File?) onImageSelected;

  const BottomContentProfile({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.currentPhotoUrl,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Profile Photo section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // gradient: LinearGradient(
                          //   colors: [
                          //     Colors.grey.shade50,
                          //     Colors.grey.shade100,
                          //   ],
                          // ),
                          // borderRadius: BorderRadius.circular(12),
                          // border: Border.all(
                          //   color: const Color(
                          //     0xFFD07C3D,
                          //   ).withOpacity(0.3),
                          //   width: 2,
                          // ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: const Color(
                          //       0xFFD07C3D,
                          //     ).withOpacity(0.1),
                          //     blurRadius: 10,
                          //     offset: const Offset(0, 4),
                          //   ),
                          // ],
                        ),
                        child: ProfilePhotoPicker(
                          initialImageUrl: currentPhotoUrl,
                          initialAssetPath: 'assets/fotoprofile.jpg',
                          onImageSelected: onImageSelected,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ketuk untuk mengubah foto profil',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                TextFieldProfile(
                  label: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  controller: nameController,
                  icon: PhosphorIcons.user(
                    PhosphorIconsStyle.regular,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFieldProfile(
                  label: 'Email',
                  hintText: 'Email tidak dapat diubah',
                  controller: emailController,
                  icon: PhosphorIcons.envelope(
                    PhosphorIconsStyle.regular,
                  ),
                  readOnly: true,
                  suffixIcon: Icon(
                    PhosphorIcons.lock(PhosphorIconsStyle.fill),
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 24),

                TextFieldProfile(
                  label: 'Password Baru',
                  hintText: 'Buat password baru',
                  controller: passwordController,
                  icon: PhosphorIcons.lock(
                    PhosphorIconsStyle.regular,
                  ),
                  isPassword: true,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Kosongkan jika tidak ingin mengubah',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}