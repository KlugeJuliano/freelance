import 'package:flutter/foundation.dart';
import 'package:freelance/models/pessoa_model.dart';
import 'package:freelance/services/supabase_client.dart';

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

      final data = await supabase
          .from('pessoas')
          .select('*, pessoa_funcao(funcao_id)')
          .order('nome');

      _pessoas = (data as List)
          .map((row) => PessoaModel.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _erro = 'Erro ao carregar colaboradores';
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

      // 1. Insere a pessoa
      final response = await supabase
          .from('pessoas')
          .insert({
            'nome': pessoa.nome,
            'cpf': pessoa.cpf,
            'telefone': pessoa.telefone,
            'email': pessoa.email,
            'chave_pix': pessoa.chavePix,
          })
          .select('id')
          .single();

      final pessoaId = response['id'] as String;

      // 2. Salva os vínculos de função na pessoa_funcao
      if (pessoa.funcaoIds.isNotEmpty) {
        final vinculos = pessoa.funcaoIds
            .map((fid) => {'pessoa_id': pessoaId, 'funcao_id': fid})
            .toList();
        await supabase.from('pessoa_funcao').insert(vinculos);
      }

      // 3. Re-fetch para garantir dados consistentes com join
      await fetchPessoas();
    } catch (e) {
      _erro = 'Falha ao salvar colaborador.';
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> removerPessoa(String id) async {
    try {
      // ON DELETE CASCADE cuida dos vínculos em pessoa_funcao
      await supabase.from('pessoas').delete().eq('id', id);
      _pessoas.removeWhere((p) => p.pessoaId == id);
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao excluir.';
      notifyListeners();
    }
  }
}
