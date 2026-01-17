import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/services/status_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();

    final pedidosPendentes = pedidoProvider.pedidos
        .where((p) => p.status == 'solicitado')
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Fila de pedidos'), centerTitle: true),
      body: pedidosPendentes.isEmpty
          ? const Center(child: Text("Nenhum pedido ainda"))
          : ListView.builder(
              itemCount: pedidosPendentes.length,
              itemBuilder: (context, index) {
                final pedido = pedidosPendentes[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                      'Pedido ${pedido.id}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Função: ${pedido.funcao}'),
                        Text('Quantidade: ${pedido.quantidade}'),
                        Text(
                          'Periodo: ${pedido.dataInicio} até ${pedido.dataFim}',
                        ),
                        Text('Status: ${pedido.status}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.push('rh/escala_pedidos/${pedido.id}'),
                  ),
                );
              },
            ),
    );
  }
}
