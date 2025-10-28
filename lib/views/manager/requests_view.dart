import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class GerenteView extends StatefulWidget {
  const GerenteView({super.key});

  @override
  State<GerenteView> createState() => _GerenteViewState();
}

class _GerenteViewState extends State<GerenteView> {
  bool status = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          context.go('/');
        }, icon: const Icon(Icons.arrow_back)),
        title: const Text('Pedidos - Gerente'),),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
          itemBuilder: (context, itens){
          
        return Card(
          child: ListTile(
            title: Text('Solicitção para 25/12/2025 ${itens + 1}'),
            subtitle: const Text('Solicitação de 5 pessoas para o setor de Reposição.'),
            onTap: (){
              context.push('/manager/jornada_view');
            },
            trailing: ElevatedButton(

              onPressed: () {

                // Ação ao aprovar o pedido
                if (status == true) {
                  setState(() {
                    status = false;
                  });
                }else{
                  setState(() {
                    status = true;
                  });
                }
              },
              child: Text(status == true ? 'Aprovado' : 'Aprovar'),
            ),
          ),
        );
      }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          context.push('/manager/new_request');
        },
        label: Text('solicitar pessoas'),
      ),
    );
  }
}
