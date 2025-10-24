class ConfirmacaoLojaModel{
  String id;
  String pedidoId;
  String userId;
  String confirmacao;
  DateTime dataEnvio;

  ConfirmacaoLojaModel({
    required this.id,
    required this.pedidoId,
    required this.userId,
    required this.confirmacao,
    required this.dataEnvio
});

}