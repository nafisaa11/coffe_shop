import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/transaksi.dart';

class RiwayatPembelianPage extends StatelessWidget {
  const RiwayatPembelianPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transaksi = ModalRoute.of(context)?.settings.arguments as Transaksi;

    final totalHarga = transaksi.items.fold(
      0,
      (total, item) => total + (item.kopi.harga * item.jumlah),
    );

    // final daftarNamaKopi = transaksi.items
    //     .map((item) => item.kopi.nama)
    //     .toList()
    //     .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFFDEFE5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Riwayat Pembelian',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.coffee, color: Colors.white),
            ),
            title: Text(
              'No. Transaksi\n${transaksi.noTransaksi}',
              style: const TextStyle(fontSize: 14),
            ),
            // subtitle: Text(
            //   daftarNamaKopi.length > 40
            //       ? daftarNamaKopi.substring(0, 40) + '...'
            //       : daftarNamaKopi,
            //   style: const TextStyle(fontSize: 12),
            // ),
            trailing: Text(
              'Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
