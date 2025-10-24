class PedidoModel{
  String id;
  String lojaId;
  String gerenteId;
  DateTime dataInicio;
  DateTime dataFim;
  String funcao;
  int quantidade;
  String observacoes;
  String status;
  DateTime dataCriacao;

  PedidoModel({
    required this.id,
    required this.lojaId,
    required this.gerenteId,
    required this.dataInicio,
    required this.dataFim,
    required this.funcao,
    required this.quantidade,
    required this.observacoes,
    required this.status,
    required this.dataCriacao
});

}