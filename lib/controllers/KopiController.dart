import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kopi.dart';

class KopiService {
  final supabase = Supabase.instance.client;

  Future<List<Kopi>> getAllKopi() async {
    final response = await supabase.from('kopi').select();

    final data = response as List;
    return data.map((item) => Kopi.fromJson(item)).toList();
  }
}
