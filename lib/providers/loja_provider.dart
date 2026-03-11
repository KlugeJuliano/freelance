// lib/providers/loja_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freelance/models/unitystore.dart';
import 'package:freelance/services/supabase_client.dart';

class LojaProvider extends ChangeNotifier {
  List<LojaModel> _lojas = [];
  bool _loading = false;

  List<LojaModel> get lojas => _lojas;
  bool get loading => _loading;

  Future<void> fetchLojas() async {
    _loading = true;
    notifyListeners();

    final data = await supabase.from('lojas').select().order('nome');

    _lojas = (data as List).map((row) => LojaModel.fromMap(row)).toList();

    _loading = false;
    notifyListeners();
  }

  LojaModel? buscarPorId(String id) {
    try {
      return _lojas.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
