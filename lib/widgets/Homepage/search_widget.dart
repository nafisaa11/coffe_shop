// widgets/Homepage/search_widget.dart
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller; // 👈 Aktifkan dan jadikan required
  final ValueChanged<String>
  onChanged; // 👈 Jadikan required dan gunakan ValueChanged
  final String hintText;

  const SearchWidget({
    Key? key,
    required this.controller, // 👈 Sekarang wajib diisi
    required this.onChanged, // 👈 Sekarang wajib diisi
    this.hintText = 'Cari minuman seleramu ...', // Hint text default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kita akan tetap menggunakan struktur Row utama Anda jika Anda berencana menambahkan elemen lain di samping search bar.
    // Jika tidak, Row luar ini bisa dihilangkan dan langsung menggunakan Container utama search bar.
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50, // Tinggi search bar
            // padding: const EdgeInsets.symmetric(horizontal: 8), // Padding dipindah ke TextField decoration
            decoration: BoxDecoration(
              color: Colors.white, // Beri warna latar belakang
              // border: Border.all(color: Colors.grey.shade300), // Border lebih halus
              borderRadius: BorderRadius.circular(
                25.0,
              ), // BorderRadius yang lebih smooth
              boxShadow: [
                // Tambahkan sedikit shadow untuk efek kedalaman
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller, // 👈 Gunakan controller yang diterima
              onChanged:
                  onChanged, // 👈 Gunakan callback onChanged yang diterima
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                // 👇 Pindahkan ikon search ke prefixIcon untuk penempatan yang lebih baik
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                // 👇 Tambahkan suffixIcon untuk tombol clear (X)
                // Tombol clear hanya muncul jika ada teks di dalam TextField
                suffixIcon:
                    controller.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.clear(); // Hapus teks dari controller
                            onChanged(
                              '',
                            ); // Panggil onChanged dengan string kosong
                            // agar parent widget tahu bahwa query sekarang kosong
                            // dan bisa mereset filter.
                          },
                        )
                        : null, // Tidak ada suffixIcon jika TextField kosong
                border:
                    InputBorder.none, // Hilangkan border default dari TextField
                // Tambahkan content padding di dalam TextField untuk menata teks dan ikon
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(fontSize: 15), // Ukuran font teks input
            ),
          ),
        ),
        // const SizedBox(width: 12), // Biarkan ini jika Anda akan menambahkan tombol filter di sini nanti
        // Filter Button (Contoh jika Anda ingin menambahkannya nanti)
        // IconButton(
        //   icon: Icon(Icons.filter_list, color: Colors.brown),
        //   onPressed: () {
        //     // Logika untuk menampilkan filter
        //   },
        // ),
      ],
    );
  }
}
