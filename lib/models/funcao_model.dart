class FuncaoModel {
  String funcaoId;
  String nomeFuncao;
  double? valorHora;

  FuncaoModel({
    required this.funcaoId,
    required this.nomeFuncao,
    this.valorHora,
  });

  factory FuncaoModel.fromJson(Map<String, dynamic> json) {
    return FuncaoModel(
      funcaoId: json['id'],
      nomeFuncao: json['nome'],
      valorHora: json['valor_hora'] != null
          ? double.tryParse(json['valor_hora'].toString())
          : null,
    );
  }
}
