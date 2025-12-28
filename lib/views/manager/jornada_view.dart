import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:provider/provider.dart';

class DetalhesPedido extends StatelessWidget {
  final String pedidoId;

  DetalhesPedido({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    final pedido = context.watch<PedidoProvider>().buscarPorId(pedidoId);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Detalhes do pedido')),
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
                child: Table(
                  children: [
                    TableRow(children: [Text('Nome'), Text('Data')]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
