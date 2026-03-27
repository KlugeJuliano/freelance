class EmpresaModel {
  final String id;
  final String nome;
  final String cnpj;
  final String emailAdmin;

  const EmpresaModel({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.emailAdmin,
  });

  factory EmpresaModel.fromMap(Map<String, dynamic> map) => EmpresaModel(
    id: map['id'],
    nome: map['nome'],
    cnpj: map['cnpj'],
    emailAdmin: map['email_admin'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'cnpj': cnpj,
    'email_admin': emailAdmin,
  };
}
