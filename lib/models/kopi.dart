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
        'https://coffeedeets.com/wp-content/uploads/2023/03/cappuccino-what-image-e1679318626885.jpeg',
    nama: 'Kopi Susu',
    tambahan: 'Susu, Gula',
    deskripsi: 'Kopi Susu adalah minuman kopi yang dicampur dengan susu. Ada banyak varian rasa yang bisa dipilih. Jenis kopi ini sangat populer di kalangan pecinta kopi.',
    harga: 20000,
  ),
  Kopi(
    id: 2,
    gambar:
        'https://techcresendo.com/wp-content/uploads/2015/09/Black-Coffee.jpg',
    nama: 'Kopi Hitam',
    tambahan: 'Gula',
    deskripsi: 'Kopi Hitam adalah minuman kopi yang disajikan tanpa susu. Rasa kopi ini lebih kuat dan pahit. Bisa dinikmati dengan atau tanpa gula. Warnanya hitam pekat.',
    harga: 15000,
  ),
  Kopi(
    id: 3,
    gambar:
        'https://media.istockphoto.com/id/505586853/id/foto/secangkir-kacang-kopi-cappuccino-dan-arabika.jpg?s=170667a&w=0&k=20&c=BNVFGfD004jBqMijhtXxeBSDVC5OB4xh1t5xbH7HkbQ=',
    nama: 'Kopi Arabika',
    tambahan: 'Susu, Gula, Krim',
    deskripsi: 'Kopi Arabika adalah jenis kopi yang memiliki rasa yang lebih halus. Kopi ini berasal dari biji kopi Arabika yang ditanam di daerah pegunungan. Aromanya sangat khas dan nikmat.',
    harga: 25000,
  ),
];