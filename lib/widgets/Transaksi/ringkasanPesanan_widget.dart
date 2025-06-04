// widgets/transaksi/ringkasan_pesanan_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';

class RingkasanPesanan extends StatefulWidget {
  final String displayName; // Nama default yang akan ditampilkan
  final List<Map<String, dynamic>> itemDipilih;
  final int totalItem;
  final int subtotal;
  final int pajak;
  final int totalPembayaran;
  final Function(String)? onNamaChanged; // Callback untuk update nama

  const RingkasanPesanan({
    super.key,
    required this.displayName,
    required this.itemDipilih,
    required this.totalItem,
    required this.subtotal,
    required this.pajak,
    required this.totalPembayaran,
    this.onNamaChanged, // Optional callback
  });

  @override
  State<RingkasanPesanan> createState() => _RingkasanPesananState();
}

class _RingkasanPesananState extends State<RingkasanPesanan> {
  late TextEditingController namaPembeliController;

  @override
  void initState() {
    super.initState();
    // Set nilai awal dari TextField ke displayName
    namaPembeliController = TextEditingController(text: widget.displayName);
  }

  @override
  void didUpdateWidget(RingkasanPesanan oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller jika displayName berubah dari parent
    if (oldWidget.displayName != widget.displayName) {
      namaPembeliController.text = widget.displayName;
    }
  }

  @override
  void dispose() {
    namaPembeliController.dispose();
    super.dispose();
  }

  String formatRupiah(int harga) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input nama pembeli
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Pembeli',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: namaPembeliController,
                onChanged: (value) {
                  // Panggil callback jika ada
                  if (widget.onNamaChanged != null) {
                    widget.onNamaChanged!(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan nama Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.brown.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.brown,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.brown.shade50.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Card utama pesanan
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset("assets/kopiqu.png", height: 35),
              ),
              const Divider(height: 1, thickness: 0.5),

              if (widget.itemDipilih.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tidak ada item yang dipilih untuk dipesan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.itemDipilih.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                        indent: 16,
                        endIndent: 16,
                      ),
                  itemBuilder: (context, index) {
                    final item = widget.itemDipilih[index];
                    final Kopi kopi = item['kopi'] as Kopi;
                    final int jumlah = item['jumlah'] as int;
                    final String ukuran = item['ukuran'] as String? ?? 'Sedang';

                    int hargaSatuan = kopi.harga;
                    if (ukuran == 'Besar') {
                      hargaSatuan += 5000;
                    } else if (ukuran == 'Kecil') {
                      hargaSatuan -= 3000;
                      if (hargaSatuan < 0) hargaSatuan = 0;
                    }
                    final int totalHargaItem = hargaSatuan * jumlah;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                kopi.gambar.startsWith('http')
                                    ? Image.network(
                                      kopi.gambar,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          alignment: Alignment.center,
                                          color: Colors.grey[200],
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.brown),
                                              ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    )
                                    : Image.asset(
                                      kopi.gambar,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 30,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kopi.nama_kopi,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ukuran: $ukuran',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${formatRupiah(hargaSatuan)} /pcs',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'x $jumlah',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.brown[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatRupiah(totalHargaItem),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Ringkasan pembayaran
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBiayaRow(
                'Subtotal (${widget.totalItem} Produk)',
                formatRupiah(widget.subtotal),
              ),
              const SizedBox(height: 8),
              _buildBiayaRow('Pajak (10%)', formatRupiah(widget.pajak)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 0.5),
              ),
              _buildBiayaRow(
                'Total Pembayaran',
                formatRupiah(widget.totalPembayaran),
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBiayaRow(String label, String nilai, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.brown : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          nilai,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? Colors.brown : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
