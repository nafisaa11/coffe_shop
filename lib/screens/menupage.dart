import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:kopiqu/widgets/KopiQu_header.dart';
import 'package:kopiqu/widgets/kopi_card.dart';
import 'package:kopiqu/widgets/search_widget.dart';
import 'package:kopiqu/widgets/tag_list.dart';
import 'package:kopiqu/widgets/navbar_bottom.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedIndex = 0; // misal default index menu di navbar-nya 1

void onItemSelected(int index) {
  setState(() {
    selectedIndex = index;
  });

  if (index == 0) {
    if (ModalRoute.of(context)!.settings.name != '/menu') {
      Navigator.pushReplacementNamed(context, '/menu');
    }
  } else if (index == 1) {
    if (ModalRoute.of(context)!.settings.name != '/home') {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } else if (index == 2) {
    if (ModalRoute.of(context)!.settings.name != '/profile') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: CustomScrollView(
              slivers: [
                // search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SearchWidget(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // tag list
                const SliverToBoxAdapter(child: TagList()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // grid kopi
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CoffeeCard(kopi: kopiList[index]);
                      },
                      childCount: kopiList.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: KopiQuHeader(),
          ),
        ],
      ),
      bottomNavigationBar: NavbarBottom(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
