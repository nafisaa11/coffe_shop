import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UkuranGelasWidget extends StatefulWidget {
  final Function(String) onUkuranDipilih;
  final int hargaAsli; // Tambahan parameter untuk harga asli

  const UkuranGelasWidget({
    super.key, 
    required this.onUkuranDipilih,
    required this.hargaAsli,
  });

  @override
  State<UkuranGelasWidget> createState() => _UkuranGelasWidgetState();
}

class _UkuranGelasWidgetState extends State<UkuranGelasWidget> {
  String _ukuranTerpilih = 'Kecil';

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, Map<String, dynamic>> ukuranData = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi data ukuran dengan harga yang diterima
    ukuranData.addAll({
      'Kecil': {
        'label': 'Kecil',
        'tambahan': 0,
        'harga': widget.hargaAsli,
      },
      'Sedang': {
        'label': 'Sedang',
        'tambahan': 3000,
        'harga': widget.hargaAsli + 3000,
      },
      'Besar': {
        'label': 'Besar',
        'tambahan': 5000,
        'harga': widget.hargaAsli + 5000,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ukuranData.entries.map((entry) {
        final ukuran = entry.key;
        final data = entry.value;
        final isSelected = _ukuranTerpilih == ukuran;
        
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: isSelected ? 4 : 1,
            shadowColor: isSelected ? Color(0xFF8B4513).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _ukuranTerpilih = ukuran;
                });
                widget.onUkuranDipilih(ukuran);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected ? Color(0xFF8B4513) : Colors.white,
                  border: Border.all(
                    color: isSelected ? Color(0xFF8B4513) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Size Icon
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? Colors.white.withOpacity(0.2) 
                          : Color(0xFF8B4513).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForSize(ukuran),
                        color: isSelected ? Colors.white : Color(0xFF8B4513),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    
                    // Size Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['label'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Color(0xFF8B4513),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getSizeDescription(ukuran),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                ? Colors.white.withOpacity(0.8) 
                                : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Price Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatRupiah.format(data['harga']),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Color(0xFF8B4513),
                          ),
                        ),
                        if (data['tambahan'] > 0) ...[
                          SizedBox(height: 2),
                          Text(
                            '+${formatRupiah.format(data['tambahan'])}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected 
                                ? Colors.white.withOpacity(0.8) 
                                : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Selection Indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: Color(0xFF8B4513),
                          )
                        : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForSize(String size) {
    switch (size) {
      case 'Kecil':
        return Icons.coffee;
      case 'Sedang':
        return Icons.local_cafe;
      case 'Besar':
        return Icons.local_cafe;
      default:
        return Icons.local_cafe;
    }
  }

  String _getSizeDescription(String size) {
    switch (size) {
      case 'Kecil':
        return '240ml';
      case 'Sedang':
        return '360ml';
      case 'Besar':
        return '480ml';
      default:
        return '';
    }
  }
}