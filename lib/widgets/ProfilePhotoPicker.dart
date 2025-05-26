import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePhotoPicker extends StatefulWidget {
  final String initialImage;
  final Function(File?) onImageSelected;

  const ProfilePhotoPicker({
    super.key,
    required this.initialImage,
    required this.onImageSelected,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _selectedImage = file);
      widget.onImageSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _selectedImage != null ? FileImage(_selectedImage!) : AssetImage(widget.initialImage);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue,
          child: CircleAvatar(
            radius: 56,
            backgroundImage: image as ImageProvider,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        )
      ],
    );
  }
}
