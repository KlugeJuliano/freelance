import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/pessoa_provider.dart';
import 'package:provider/provider.dart';

class DetalhesPedido extends StatelessWidget {
  final String pedidoId;

  const DetalhesPedido({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();
    final pessoaProvider = context.watch<PessoaProvider>();

    final pedido = pedidoProvider.buscarPorId(pedidoId);
    final pessoasNoPedido = pedido.pessoas;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detalhes do pedido'),
        leading: BackButton(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        child: Row(
          children: [
            ElevatedButton(onPressed: () {}, child: Text('Cancelar')),
            ElevatedButton(onPressed: () {}, child: Text('Finalizar')),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Card(
          child: Column(
            children: [
              Text(
                'Pedido id: ${pedido.id} para ${pedido.dataInicio} status: ${pedido.status}',
              ),
              const SizedBox(height: 4),
              Text('Relação das pessoas selecionadas:'),
              const SizedBox(height: 4),
              SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Expanded(child: Text('Nome'))),
                    DataColumn(label: Expanded(child: Text('Função'))),
                  ],
                  rows: pessoasNoPedido.map<DataRow>((pessoaNoPedido) {
                    final pessoa = pessoaProvider.buscarPessoaPorId(
                      pessoaNoPedido.pessoaId,
                    );

                    return DataRow(
                      cells: [
                        DataCell(Text(pessoa.nome)),
                        DataCell(Text(pessoaNoPedido.funcao)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
