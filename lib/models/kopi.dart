class Kopi {
  int id;
  String gambar;
  String nama;
  String tambahan;
  String deskripsi;
  int harga;

  Kopi({
    required this.id,
    required this.gambar,
    required this.nama,
    required this.tambahan,
    required this.deskripsi,
    required this.harga,
  });
}

var kopiList = [
  Kopi(
    id: 1,
    gambar:
        'assets/matcha.jpg',
    nama: 'Kopi Susu',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Susu adalah minuman kopi yang dicampur dengan susu. Ada banyak varian rasa yang bisa dipilih. Jenis kopi ini sangat populer di kalangan pecinta kopi.',
    harga: 20000,
  ),
  Kopi(
    id: 2,
    gambar:
        'assets/matcha.jpg',
    nama: 'Kopi Hitam',
    tambahan: 'Gula',
    deskripsi: 'Kopi Hitam adalah minuman kopi yang disajikan tanpa susu. Rasa kopi ini lebih kuat dan pahit. Bisa dinikmati dengan atau tanpa gula. Warnanya hitam pekat.',
    harga: 15000,
  ),
  Kopi(
    id: 3,
    gambar:
        'assets/matcha.jpg',
    nama: 'Kopi Arabika',
    tambahan: 'Susu, Gula, Krim',
    deskripsi: 'Kopi Arabika adalah jenis kopi yang memiliki rasa yang lebih halus. Kopi ini berasal dari biji kopi Arabika yang ditanam di daerah pegunungan. Aromanya sangat khas dan nikmat.',
    harga: 25000,
  ),
  Kopi(
    id: 4,
    gambar:
        'assets/matcha.jpg',
    nama: 'Matcha Latte',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Robusta adalah jenis kopi yang memiliki rasa yang lebih kuat dan pahit. Kopi ini berasal dari biji kopi Robusta yang ditanam di daerah dataran rendah.',
    harga: 18000,
  ),
   Kopi(
    id: 5,
    gambar:
        'assets/matcha.jpg',
    nama: 'Matcha Latte',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Robusta adalah jenis kopi yang memiliki rasa yang lebih kuat dan pahit. Kopi ini berasal dari biji kopi Robusta yang ditanam di daerah dataran rendah.',
    harga: 18000,
  ),
   Kopi(
    id: 6,
    gambar:
        'assets/matcha.jpg',
    nama: 'Matcha Latte',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Robusta adalah jenis kopi yang memiliki rasa yang lebih kuat dan pahit. Kopi ini berasal dari biji kopi Robusta yang ditanam di daerah dataran rendah.',
    harga: 18000,
  ),
];