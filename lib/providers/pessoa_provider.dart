import 'package:flutter/foundation.dart';
import '../models/pessoa_model.dart';
import '../services/supabase_client.dart';

class PessoaProvider extends ChangeNotifier {
  List<PessoaModel> _pessoas = [];
  bool _loading = false;
  String? _erro;

  List<PessoaModel> get pessoas => _pessoas;
  bool get loading => _loading;
  String? get erro => _erro;

  Future<void> fetchPessoas() async {
    try {
      _loading = true;
      _erro = null;
      notifyListeners();

      final data = await supabase.from('pessoas').select().order('nome');
      _pessoas = (data as List).map((row) => PessoaModel.fromMap(row)).toList();
    } catch (e) {
      _erro = "Erro ao carregar colaboradores";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarPessoa(PessoaModel pessoa) async {
    try {
      _loading = true;
      _erro = null;
      notifyListeners();

      final response = await supabase
          .from('pessoas')
          .insert({
            'nome': pessoa.nome,
            'cpf': pessoa.cpf,
            'telefone': pessoa.telefone,
            'email': pessoa.email,
            'chave_pix': pessoa.chavePix,
            // No Postgres, use o tipo JSONB ou Array
          })
          .select()
          .single();

      _pessoas.add(PessoaModel.fromMap(response));
      _pessoas.sort((a, b) => a.nome.compareTo(b.nome));
    } catch (e) {
      print("ERRO SUPABASE: $e");

      _erro = "Falha ao salvar colaborador.";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> removerPessoa(String id) async {
    try {
      await supabase.from('pessoas').delete().eq('id', id);
      _pessoas.removeWhere((p) => p.pessoaId == id);
      notifyListeners();
    } catch (e) {
      _erro = "Erro ao excluir.";
      notifyListeners();
    }
  }
}
