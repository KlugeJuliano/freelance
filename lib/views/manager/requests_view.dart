import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GerenteView extends StatelessWidget {
  const GerenteView({super.key});

  @override
  Widget build(BuildContext context) {
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
          itemBuilder: (context, itens) {
            return Card(
              child: ListTile(
                title: Text('Solicitação para 25/12/2025 ${itens + 1}'),
                subtitle: const Text(
                  'Solicitação de 5 pessoas para o setor de Reposição.',
                ),
                onTap: () {
                  context.push('/manager/jornada_view');
                },
                trailing: ElevatedButton(
                  onPressed: () {},

                  child: Text("aprover"),
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
