import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/models/transaksi.dart';

final dummyTransaksi = Transaksi(
  pembeli: 'Sinta',
  noTransaksi: 'CKQ-20250504-0001',
  tanggal: DateTime(2025, 5, 4, 11, 0),
  items: [
    ItemTransaksi(kopi: kopiList[0], jumlah: 2),
    ItemTransaksi(kopi: kopiList[1], jumlah: 2),
    ItemTransaksi(kopi: kopiList[2], jumlah: 2),
    ItemTransaksi(kopi: kopiList[3], jumlah: 2),
  ],
);
