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
        'https://i.ibb.co/F4GmpsgK/cappuccino-what-image-e1679318626885.jpg',
    nama: 'Kopi Susu',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Susu adalah minuman kopi yang dicampur dengan susu. Ada banyak varian rasa yang bisa dipilih. Jenis kopi ini sangat populer di kalangan pecinta kopi.',
    harga: 20000,
  ),
  Kopi(
    id: 2,
    gambar:
        'https://i.ibb.co/v4xG3nRc/download-6.jpg',
    nama: 'Kopi Hitam',
    tambahan: 'Gula',
    deskripsi: 'Kopi Hitam adalah minuman kopi yang disajikan tanpa susu. Rasa kopi ini lebih kuat dan pahit. Bisa dinikmati dengan atau tanpa gula. Warnanya hitam pekat.',
    harga: 15000,
  ),
  Kopi(
    id: 3,
    gambar:
        'https://i.ibb.co/HTwkJH51/Easy-Vanilla-Matcha-Latte-Quick-Healthy-Treat-for-Busy-Mornings.jpg',
    nama: 'Kopi Arabika',
    tambahan: 'Susu, Gula, Krim',
    deskripsi: 'Kopi Arabika adalah jenis kopi yang memiliki rasa yang lebih halus. Kopi ini berasal dari biji kopi Arabika yang ditanam di daerah pegunungan. Aromanya sangat khas dan nikmat.',
    harga: 25000,
  ),
  Kopi(
    id: 4,
    gambar:
        'https://i.ibb.co/cc3WPNwq/download-7.jpg',
    nama: 'Matcha Latte',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Robusta adalah jenis kopi yang memiliki rasa yang lebih kuat dan pahit. Kopi ini berasal dari biji kopi Robusta yang ditanam di daerah dataran rendah.',
    harga: 18000,
  ),
];