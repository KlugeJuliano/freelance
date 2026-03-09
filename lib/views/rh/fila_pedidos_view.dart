import 'package:flutter/material.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PedidoProvider>().carregarPedidos();
    });
  }

  Drawer buildDrawer(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu RH',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('Cadastro de Funções'),
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_funcoes');
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Cadastro de Colaboradores'),
            onTap: () {
              Navigator.pop(context);
              context.push('/rh/cadastros/cadastro_colaboradores');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () async {
              await auth.logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProvider = context.watch<PedidoProvider>();

    final pedidosPendentes = pedidoProvider.pedidos
        .where((p) => p.status == 'solicitado')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Fila de Pedidos'), centerTitle: true),

      drawer: buildDrawer(context),

      body: pedidoProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : pedidosPendentes.isEmpty
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Função: ${pedido.funcaoId}'),
                        Text('Quantidade: ${pedido.quantidade}'),
                        Text(
                          'Período: ${pedido.dataInicio} até ${pedido.dataFim}',
                        ),
                        Text('Status: ${pedido.status}'),
                      ],
                    ),

                    trailing: const Icon(Icons.arrow_forward),

                    onTap: () {
                      context.push(
                        '/rh/escala_pedidos/${pedido.id}',
                        extra: pedido,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
