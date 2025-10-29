import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FilaPedidosView extends StatefulWidget {
  const FilaPedidosView({super.key});

  @override
  State<FilaPedidosView> createState() => _FilaPedidosViewState();
}

class _FilaPedidosViewState extends State<FilaPedidosView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fila de pedidos'),
      centerTitle: true,),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solicitação #12345', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('Loja: Loja Central'),
                    Text('Gerente: João Silva'),
                    Text('Data: 25/06/2024'),
                    Text('Pessoas solicitadas: 3'),
                    Text('Status: Em andamento'),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Ação ao pressionar o botão
                        context.push('/rh/escala_pedidos');
                      },
                      child: Text('Ver detalhes do pedido'),
                    ),
                  ],
                ),
              ),
             ),
              Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação #12346', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
                      Text('Loja: Loja Norte'),
                      Text('Gerente: Maria Oliveira'),
                      Text('Data: 26/06/2024'),
                      Text('Pessoas solicitadas: 2'),
                      Text('Status: Pendente'),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Ação ao pressionar o botão
                        },
                        child: Text('Ver detalhes do pedido'),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solicitação #12347', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.0),
                      Text('Loja: Loja Sul'),
                      Text('Gerente: Carlos Pereira'),
                      Text('Data: 27/06/2024'),
                      Text('Pessoas solicitadas: 4'),
                      Text('Status: Aprovado'),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          // Ação ao pressionar o botão
                        },
                        child: Text('Ver detalhes do pedido'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
