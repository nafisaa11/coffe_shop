import 'package:flutter/material.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedIndex = 2;
  
void onItemSelected(int index) {
  setState(() {
    selectedIndex = index;
  });

  if (index == 0) {
    if (ModalRoute.of(context)!.settings.name != '/menu') {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  } else if (index == 1) {
    if (ModalRoute.of(context)!.settings.name != '/home') {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else if (index == 2) {
    if (ModalRoute.of(context)!.settings.name != '/profile') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Halaman Profile (Kosong)')),
      bottomNavigationBar: NavbarBottom(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
