import 'package:flutter/material.dart';

class EscalacaoView extends StatefulWidget {
  const EscalacaoView({super.key});

  @override
  State<EscalacaoView> createState() => _EscalacaoViewState();
}

class _EscalacaoViewState extends State<EscalacaoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escalação de pedidos'), centerTitle: true),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOLICITAÇÃO: 123456',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Gerente Responsável: João Silva',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Data da Solicitação: 01/01/2024',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Data Limite: 15/01/2024', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Pessoas Necessárias: 5', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Departamento: Vendas', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Descrição: Necessidade de contratação de novos funcionários para o setor de vendas.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Ação ao pressionar o botão
              },
              child: Text('Escalar Pessoas'),
            ),
          ],
        ),
      ),
    );
  }
}
