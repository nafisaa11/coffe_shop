class Kopi {
  final int id;
  final String gambar;
  final String nama_kopi;
  final String komposisi;
  final String deskripsi;
  final int harga;

  Kopi({
    required this.id,
    required this.gambar,
    required this.nama_kopi,
    required this.komposisi,
    required this.deskripsi,
    required this.harga,
  });

  factory Kopi.fromMap(Map<String, dynamic> map) {
    return Kopi(
      id: map['id'],
      gambar: map['gambar'] ?? 'Tidak ada gambar',
      nama_kopi: map['nama_kopi'] ?? 'Tidak ada nama',
      komposisi: map['komposisi'] ?? 'Tidak ada komposisi',
      deskripsi: map['deskripsi'] ?? 'Tidak ada deskripsi',
      harga: map['harga'] ?? 0,
    );
  }

  static List<Kopi> listFromJson(List<dynamic> data) {
    return data.map((item) => Kopi.fromMap(item)).toList();
  }
}
