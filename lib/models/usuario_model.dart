class UsuarioModel {
  final String id;
  final String empresaId;
  final String nome;
  final String email;
  final String role;

  const UsuarioModel({
    required this.id,
    required this.empresaId,
    required this.nome,
    required this.email,
    required this.role,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
    id: map['id'],
    empresaId: map['empresa_id'],
    nome: map['nome'],
    email: map['email'],
    role: map['role'],
  );

  String get roleLabel {
    switch (role) {
      case 'diretoria':
        return 'Diretoria';
      case 'rh':
        return 'RH';
      case 'gerente':
        return 'Gerente';
      default:
        return role;
    }
  }
}