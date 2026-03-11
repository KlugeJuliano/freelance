// lib/models/loja_model.dart

class LojaModel {
  final String id;
  final String nomeLoja;
  final String? endereco;

  LojaModel({required this.id, required this.nomeLoja, this.endereco});

  factory LojaModel.fromMap(Map<String, dynamic> map) {
    return LojaModel(
      id: map['id'] as String,
      nomeLoja: map['nome'] as String,
      endereco: map['endereco'] as String?,
    );
  }
}
