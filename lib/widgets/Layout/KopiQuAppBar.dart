import 'package:flutter/material.dart';
import 'package:kopiqu/controllers/Keranjang_Controller.dart'; 
import 'package:provider/provider.dart';

class KopiQuAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey cartIconKey; 

  const KopiQuAppBar({super.key, required this.cartIconKey});

  @override
  Widget build(BuildContext context) {
    const SizedBox(width: 20);
    return AppBar(
      title: Image.asset(
        'assets/kopiqu.png',
        width: 120,
      ),
      backgroundColor: Color(0xFFD07C3D), 
      foregroundColor:
          Colors
              .white, 
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 10.0,
            top: 4.0,
            bottom: 4.0,
          ), // Padding untuk keseluruhan actions
          child: Consumer<KeranjangController>(
            builder: (context, keranjangController, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    key:
                        cartIconKey,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: Colors.white, 
                    iconSize: 28,
                    tooltip: 'Keranjang Belanja',
                    onPressed: () {
                      // Navigasi ke halaman keranjang
                      Navigator.pushNamed(
                        context,
                        '/keranjang',
                      );
                    },
                  ),
                  // Badge jumlah item
                  if (keranjangController.totalItemDiKeranjang > 0)
                    Positioned(
                      right: 6, 
                      top: 6, 
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent, // Warna badge
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${keranjangController.totalItemDiKeranjang}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
