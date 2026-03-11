// lib/models/pessoa_no_pedido.dart

class PessoaNoPedidoModel {
  final String pessoaId;
  final String nome;
  final String funcao;
  final String? status;

  PessoaNoPedidoModel({
    required this.pessoaId,
    required this.nome,
    required this.funcao,
    this.status,
  });

  /// Espera um retorno do Supabase semelhante a:
  ///
  /// pedido_escalacao
  /// └── pessoas
  ///     └── pessoa_funcao
  ///         └── funcoes(nome)

  factory PessoaNoPedidoModel.fromMap(Map<String, dynamic> map) {
    final pessoa = map['pessoas'] as Map<String, dynamic>? ?? {};

    final List funcoes = pessoa['pessoa_funcao'] as List? ?? [];

    String nomeFuncao = '';

    if (funcoes.isNotEmpty) {
      final funcaoData = funcoes.first['funcoes'] as Map<String, dynamic>?;

      if (funcaoData != null) {
        nomeFuncao = funcaoData['nome'] as String? ?? '';
      }
    }

    return PessoaNoPedidoModel(
      pessoaId: map['pessoa_id'] as String? ?? '',
      nome: pessoa['nome'] as String? ?? '',
      funcao: nomeFuncao,
      status: map['status'] as String?,
    );
  }

  PessoaNoPedidoModel copyWith({
    String? pessoaId,
    String? nome,
    String? funcao,
    String? status,
  }) {
    return PessoaNoPedidoModel(
      pessoaId: pessoaId ?? this.pessoaId,
      nome: nome ?? this.nome,
      funcao: funcao ?? this.funcao,
      status: status ?? this.status,
    );
  }
}
