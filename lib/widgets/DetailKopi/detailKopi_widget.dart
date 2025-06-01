import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/DetailKopi/ukuranGelas_widget.dart';
import 'package:provider/provider.dart';

class DetailWidget extends StatefulWidget {
  final Kopi kopi;
  final Function(String ukuran) onTambah;

  const DetailWidget({super.key, required this.kopi, required this.onTambah});

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  String ukuranDipilih = 'Kecil';
  List<String> _komposisiItems = [];

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Fungsi untuk menghitung harga berdasarkan ukuran
  int _hitungHargaByUkuran(String ukuran) {
    switch (ukuran) {
      case 'Kecil':
        return widget.kopi.harga; // Harga asli
      case 'Sedang':
        return widget.kopi.harga + 3000; // Harga asli + 3000
      case 'Besar':
        return widget.kopi.harga + 5000; // Harga asli + 5000
      default:
        return widget.kopi.harga;
    }
  }

  List<String> _generateItemsFromKomposisi(String? komposisiString) {
    if (komposisiString == null || komposisiString.trim().isEmpty) {
      return [];
    }
    return komposisiString
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _komposisiItems = _generateItemsFromKomposisi(widget.kopi.komposisi);
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF8B4513).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Color(0xFF8B4513), size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKomposisiTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8B4513).withOpacity(0.1),
            Color(0xFF8B4513).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF8B4513).withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Color(0xFF8B4513),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Color(0xFF8B4513),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kopi = widget.kopi;
    final hargaSaatIni = _hitungHargaByUkuran(ukuranDipilih);

    Widget komposisiSection;
    if (_komposisiItems.isNotEmpty) {
      komposisiSection = Wrap(
        spacing: 10.0,
        runSpacing: 8.0,
        children:
            _komposisiItems.map((item) => _buildKomposisiTag(item)).toList(),
      );
    } else {
      komposisiSection = Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Informasi komposisi tidak tersedia.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF8F6F0),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Komposisi Section
                    if (_komposisiItems.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.local_cafe_outlined,
                        title: 'Komposisi',
                        subtitle: 'Bahan-bahan dalam kopi ini',
                      ),
                      SizedBox(height: 16),
                      komposisiSection,
                      SizedBox(height: 32),
                    ],

                    // Ukuran Kopi Section
                    _buildSectionHeader(
                      icon: Icons.coffee_maker_outlined,
                      title: 'Pilih Ukuran',
                      subtitle: 'Sesuaikan dengan kebutuhan Anda',
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: UkuranGelasWidget(
                        hargaAsli: widget.kopi.harga,
                        onUkuranDipilih: (ukuran) {
                          setState(() {
                            ukuranDipilih = ukuran;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 32),

                    // Deskripsi Section
                    _buildSectionHeader(
                      icon: Icons.description_outlined,
                      title: 'Tentang Kopi Ini',
                      subtitle: 'Rasa dan karakteristik unik',
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF8B4513).withOpacity(0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            kopi.deskripsi,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ), // Extra padding for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<KeranjangController>(
        builder: (context, keranjangCtrl, _) {
          final sudahAda = keranjangCtrl.sudahAda(widget.kopi, ukuranDipilih);

          return Container(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Price Section
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatRupiah.format(hargaSaatIni),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  // Button Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (sudahAda) {
                            Navigator.pushNamed(context, '/keranjang');
                          } else {
                            Provider.of<KeranjangController>(
                              context,
                              listen: false,
                            ).tambah(widget.kopi, ukuranDipilih);
                            widget.onTambah(ukuranDipilih);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Color(0xFF8B4513).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sudahAda
                                  ? Icons.shopping_cart_checkout
                                  : Icons.add_shopping_cart,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              sudahAda
                                  ? 'Lihat Keranjang'
                                  : 'Tambah',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}