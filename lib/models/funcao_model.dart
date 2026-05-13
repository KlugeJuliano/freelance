class FuncaoModel {
  final String id;
  final String empresaId;
  final String nomeFuncao;
  final double? valorHora;

  const FuncaoModel({
    required this.id,
    required this.empresaId,
    required this.nomeFuncao,
    this.valorHora,
  });

  // Alias para compatibilidade com as views existentes
  String get funcaoId => id;

  factory FuncaoModel.fromMap(Map<String, dynamic> map) => FuncaoModel(
    id: map['id'],
    empresaId: map['empresa_id'],
    nomeFuncao: map['nome_funcao'],
    valorHora: (map['valor_hora'] as num?)?.toDouble(),
  );
}
