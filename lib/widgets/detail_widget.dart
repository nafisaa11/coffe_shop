import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/ukuranGelas_widget.dart';

class DetailWidget extends StatefulWidget {
  final Kopi kopi;
  final Function(String ukuran) onTambah;

  const DetailWidget({super.key, required this.kopi, required this.onTambah});

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  String ukuranDipilih = 'Kecil';

  @override
  Widget build(BuildContext context) {
    final kopi = widget.kopi;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              _buildTag('Coffee'),
              _buildTag('Chocolate'),
              _buildTag('Milk Foam'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ukuran Kopi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          UkuranGelasWidget(
            onUkuranDipilih: (ukuran) {
              setState(() {
                ukuranDipilih = ukuran;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Tentang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(kopi.deskripsi),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.brown[50],
      labelStyle: TextStyle(color: Colors.brown),
    );
  }
}
