import 'package:flutter/material.dart';

class KeranjangWidget extends StatelessWidget {
  const KeranjangWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang KopiQu'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Keranjang Kosong',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),    
    );
  }
}