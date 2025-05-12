import 'package:flutter/material.dart';

class UkuranGelasWidget extends StatefulWidget {
  final Function(String) onUkuranDipilih;

  const UkuranGelasWidget({super.key, required this.onUkuranDipilih});

  @override
  State<UkuranGelasWidget> createState() => _UkuranGelasWidgetState();
}

class _UkuranGelasWidgetState extends State<UkuranGelasWidget> {
  String _ukuranTerpilih = 'Kecil';

  final List<String> ukuranList = ['Kecil', 'Sedang', 'Besar'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: ukuranList.map((label) {
        final isSelected = _ukuranTerpilih == label;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _ukuranTerpilih = label;
            });
            widget.onUkuranDipilih(label);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.brown : Colors.brown[100],
            foregroundColor: isSelected ? Colors.white : Colors.brown,
            shape: const StadiumBorder(),
          ),
          child: Text(label),
        );
      }).toList(),
    );
  }
}
