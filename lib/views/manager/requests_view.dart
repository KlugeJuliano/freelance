import 'package:flutter/material.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListaPedidosView extends StatefulWidget {
  const ListaPedidosView({super.key});

  @override
  State<ListaPedidosView> createState() => _ListaPedidosViewState();
}

class _ListaPedidosViewState extends State<ListaPedidosView> {
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PedidoProvider>().carregarPedidos());
  }

  Future<void> _recarregar() async {
    await context.read<PedidoProvider>().carregarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _recarregar),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: pedidoProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : pedidoProvider.erro != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pedidoProvider.erro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _recarregar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : pedidoProvider.pedidos.isEmpty
          ? const Center(child: Text('Nenhum pedido criado ainda'))
          : RefreshIndicator(
              onRefresh: _recarregar,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pedidoProvider.pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidoProvider.pedidos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        'Pedido #${pedido.id.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantidade: ${pedido.quantidade}'),
                          Text(
                            'Período: ${_dateFormat.format(pedido.dataInicio)} → ${_dateFormat.format(pedido.dataFim)}',
                          ),
                          Chip(
                            label: Text(pedido.status),
                            backgroundColor: _corStatus(pedido.status),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () =>
                          context.push('/manager/jornada_view/${pedido.id}'),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/manager/new_request'),
        icon: const Icon(Icons.add),
        label: const Text('Solicitar pessoas'),
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'solicitado':
        return Colors.blue.shade100;
      case 'em_selecao':
        return Colors.orange.shade100;
      case 'aguardando_aprovacao':
        return Colors.yellow.shade100;
      case 'aprovado':
        return Colors.green.shade100;
      case 'em_andamento':
        return Colors.teal.shade100;
      case 'aguardando_finalizacao':
        return Colors.purple.shade100;
      case 'concluido':
        return Colors.grey.shade300;
      case 'cancelado':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
