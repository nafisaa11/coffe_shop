import 'package:flutter/material.dart';
import 'package:kopiqu/models/kopi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kopiCard_widget.dart';

class KopiGrid extends StatefulWidget {
  const KopiGrid({super.key});

  @override
  State<KopiGrid> createState() => _KopiGridState();
}

class _KopiGridState extends State<KopiGrid> {
  List<Kopi> _data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('kopi').select('*');

    setState(() {
      _data = (response as List)
          .map((json) => Kopi.fromMap(json))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: _data.isEmpty
          ? const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          : SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CoffeeCard(kopi: _data[index]);
                },
                childCount: _data.length,
              ),
            ),
    );
  }
}

