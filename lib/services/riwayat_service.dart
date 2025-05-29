// services/riwayat_service.dart
import 'package:kopiqu/models/transaksi.dart'; // Model Transaksi Anda yang sudah ada
import 'package:kopiqu/models/riwayat_transaksi.dart'; // Model RiwayatTransaksi yang baru dibuat
import 'package:supabase_flutter/supabase_flutter.dart';

// Class ini bertanggung jawab untuk semua interaksi terkait riwayat transaksi dengan database Supabase.
class RiwayatService {
  final _supabase = Supabase.instance.client;

  // Method untuk menyimpan transaksi baru (dari objek Transaksi) ke tabel 'riwayat_transaksi' di Supabase
  Future<void> simpanTransaksiKeSupabase(Transaksi transaksi) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print('Error: Pengguna tidak login. Riwayat tidak dapat disimpan.');
      throw Exception('Pengguna tidak login. Riwayat tidak dapat disimpan.');
    }

    try {
      // Data yang akan diinsert ke tabel 'riwayat_transaksi'
      // Pastikan key di Map ini sesuai dengan nama kolom di tabel Supabase Anda.
      final dataToInsert = {
        'user_id': userId,
        'nomor_struk': transaksi.id, // ID unik dari model Transaksi Anda
        'nama_pembeli': transaksi.pembeli,
        'items':
            transaksi
                .items, // Ini adalah List<Map<String, dynamic>> dari model Transaksi
        'total_produk': transaksi.totalProduk,
        'subtotal': transaksi.subtotal,
        'pajak': transaksi.pajak,
        'total_pembayaran': transaksi.totalPembayaran,
        'tanggal_transaksi': transaksi.tanggalTransaksi.toIso8601String(),
        // 'id' (UUID) dan 'created_at' akan di-generate/default oleh Supabase
      };

      print('[RiwayatService] Menyimpan transaksi ke Supabase: $dataToInsert');
      await _supabase.from('riwayat_transaksi').insert(dataToInsert);
      print('[RiwayatService] Transaksi berhasil disimpan ke riwayat.');
    } catch (e) {
      print(
        '[RiwayatService] Supabase Error - Gagal menyimpan transaksi ke riwayat: $e',
      );
      throw Exception('Gagal menyimpan riwayat transaksi: $e');
    }
  }

  // Method untuk mengambil daftar semua RiwayatTransaksi milik pengguna yang sedang login
  Future<List<RiwayatTransaksi>> getDaftarRiwayatPengguna() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print(
        '[RiwayatService] Pengguna tidak login, tidak bisa mengambil riwayat.',
      );
      return []; // Kembalikan list kosong jika pengguna tidak login
    }

    try {
      print('[RiwayatService] Mengambil riwayat untuk user_id: $userId');
      // Mengambil data dari tabel 'riwayat_transaksi', difilter berdasarkan 'user_id',
      // dan diurutkan berdasarkan 'tanggal_transaksi' secara descending (terbaru dulu).
      final List<Map<String, dynamic>> response = await _supabase
          .from('riwayat_transaksi')
          .select() // Ambil semua kolom
          .eq('user_id', userId)
          .order('tanggal_transaksi', ascending: false);

      if (response.isEmpty) {
        print(
          '[RiwayatService] Tidak ada riwayat ditemukan untuk pengguna ini.',
        );
        return [];
      }

      // Mengubah setiap Map (item JSON dari Supabase) menjadi objek RiwayatTransaksi
      return response
          .map((itemMap) => RiwayatTransaksi.fromMap(itemMap))
          .toList();
    } catch (e) {
      print(
        '[RiwayatService] Supabase Error - Gagal mengambil daftar riwayat: $e',
      );
      throw Exception('Gagal mengambil daftar riwayat: $e');
    }
  }
}
