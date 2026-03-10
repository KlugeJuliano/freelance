import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart'; // Assuming this provider can fetch a single pedido
import 'package:provider/provider.dart';

class JornadaView extends StatelessWidget {
  final String pedidoId;

  const JornadaView({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    // In a real scenario, you would fetch the pedido details using pedidoId
    // For now, let's just display the ID
    // final pedidoProvider = context.read<PedidoProvider>();
    // final PedidoModel? pedido = pedidoProvider.getPedidoById(pedidoId); // Example

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Jornada'),
      ),
      body: Center(
        child: Text('Detalhes do Pedido: $pedidoId'),
      ),
    );
  }
}