class RelatorioModel{
  String id;
  String pedidoId;
  String totalHoras;
  int totalFreelancers;
  int custoEstimado;
  DateTime dataCriacao;

  RelatorioModel({
    required this.id,
    required this.pedidoId,
    required this.totalHoras,
    required this.totalFreelancers,
    required this.custoEstimado,
    required this.dataCriacao
});
}