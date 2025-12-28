import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GerenteView extends StatelessWidget {
  const GerenteView({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>().pedidos;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Pedidos - Gerente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pedidoProvider.length,
          itemBuilder: (context, index) {
            final pedido = pedidoProvider[index];
            return Card(
              child: ListTile(
                title: Text(
                  'Solicitação para ${pedido.dataInicio.day}/${pedido.dataInicio.month}/${pedido.dataInicio.year}',
                ),

                subtitle: Text(
                  'Solicitação de ${pedido.quantidade} pessoas para o setor de ${pedido.funcao}.',
                ),
                onTap: () {
                  context.go('/manager/jornada_view/${pedido.id}');
                },
                trailing: ElevatedButton(
                  onPressed: () {},

                  child: Text("Aprovar"),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/manager/new_request');
        },
        label: Text('solicitar pessoas'),
      ),
    );
  }
}
