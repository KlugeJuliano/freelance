// lib/models/funcao_model.dart

class FuncaoModel {
  final String funcaoId;
  final String nomeFuncao;
  final double? valorHora;

  FuncaoModel({
    required this.funcaoId,
    required this.nomeFuncao,
    this.valorHora,
  });

  factory FuncaoModel.fromMap(Map<String, dynamic> map) {
    return FuncaoModel(
      funcaoId: map['id'] as String,
      nomeFuncao: map['nome'] as String,
      valorHora: map['valor_hora'] != null
          ? double.tryParse(map['valor_hora'].toString())
          : null,
    );
  }
}
