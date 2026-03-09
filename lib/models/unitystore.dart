class LojaModel {
  String id;
  String nomeLoja;
  String? endereco;

  LojaModel({required this.id, required this.nomeLoja, this.endereco});

  factory LojaModel.fromJson(Map<String, dynamic> json) {
    return LojaModel(
      id: json['id'],
      nomeLoja: json['nome'],
      endereco: json['endereco'],
    );
  }
}
