import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataKopi extends StatefulWidget {
  const DataKopi({Key? key}) : super(key: key);

  @override
  State<DataKopi> createState() => _DataKopiState();
}

class _DataKopiState extends State<DataKopi> {
  final supabase = Supabase.instance.client;
  List<Kopi> data = [];

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> getData() async {
    try {
      final response = await supabase.from('kopi').select('*');
      setState(() {
        data = Kopi.listFromJson(response);
      });
    } catch (e) {
      print('Error getData: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          delete();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Get Data'),
        actions: [
          IconButton(
            onPressed: () {
              getData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  leading:
                      item.gambar.isNotEmpty
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(item.gambar),
                          )
                          : CircleAvatar(backgroundColor: Colors.grey),
                  title: Text(item.nama_kopi),
                  subtitle: Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                    ).format(item.harga),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // get
  // get() async {
  //   // final response = await supabase.from('produk').select('*');
  //   final response = await supabase
  //       .from('kopi')
  //       .select('nama_kopi, harga, gambar');
  //   print(response); // Tambahkan ini
  //   setState(() {
  //     data = response;
  //   });
  // }

  //insert
  insert() async {
    try {
      final response = await supabase.from('kopi').insert({
        'nama_kopi': 'Nasi Goreng',
        'harga': 15000,
        'gambar': 'https://example.com/nasi_goreng.jpg',
      });

      // Cek jika response berhasil
      print('Insert success: $response');

      // Refresh data setelah insert
      getData();
    } catch (e) {
      print('Insert error: $e');
    }
  }

  //update
  update() async {
    try {
      final response = await supabase
          .from('kopi')
          .update({'nama_kopi': 'Mie Goreng'})
          .eq('id', 23);
      // Cek jika response berhasil
      print('Update success: $response');
      // Refresh data setelah update
      getData();
    } catch (e) {
      print('Update error: $e');
    }
  }

  // delete
  delete() async {
    try {
      final response = await supabase.from('kopi').delete().eq('id', 23);
      // Cek jika response berhasil
      print('Delete success: $response');
      // Refresh data setelah delete
      getData();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
