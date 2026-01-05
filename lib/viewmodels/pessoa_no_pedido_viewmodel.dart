class PessoaNoPedidoViewModel {
  final String pessoaId;
  final String nome;
  final String funcao;

  PessoaNoPedidoViewModel({
    required this.pessoaId,
    required this.nome,
    required this.funcao,
  });

  @override
  String toString() =>
      'PessoaNoPedidoVM(: $nome, funcao: $funcao, id: $pessoaId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PessoaNoPedidoViewModel &&
          runtimeType == other.runtimeType &&
          pessoaId == other.pessoaId;

  @override
  int get hashCode => pessoaId.hashCode;
}
