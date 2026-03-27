// lib/providers/loja_provider.dart

import 'package:flutter/foundation.dart';
import 'package:freelance/models/unitystore.dart';
import 'package:freelance/services/supabase_client.dart';

class LojaProvider extends ChangeNotifier {
  List<LojaModel> _lojas = [];
  bool _loading = false;
  String? _empresaId;

  List<LojaModel> get lojas => _lojas;
  bool get loading => _loading;

  void inicializar(String empresaId) {
    if (_empresaId == empresaId) return;
    _empresaId = empresaId;
    fetchLojas();
  }

  Future<void> fetchLojas() async {
    // Se precisar filtrar por empresa futuramente, usar _empresaId
    _loading = true;
    notifyListeners();

    try {
      final data = await supabase.from('lojas').select().order('nome');
      _lojas = (data as List).map((row) => LojaModel.fromMap(row)).toList();
    } catch (e) {
      // erro silencioso ou tratar se necessário
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  LojaModel? buscarPorId(String id) {
    try {
      return _lojas.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void limpar() {
    _lojas = [];
    _empresaId = null;
    notifyListeners();
  }
}
