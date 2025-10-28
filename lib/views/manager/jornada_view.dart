import 'package:flutter/material.dart';

class JornadaView extends StatefulWidget {
  const JornadaView({super.key});

  @override
  State<JornadaView> createState() => _JornadaViewState();
}

class _JornadaViewState extends State<JornadaView> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Jornada View'),
      ),
      body:  
      Padding(padding: EdgeInsets.all(  16.0), child:
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes da Jornada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          SizedBox(height: 24,),
          Text('Aqui estarão os detalhes da jornada selecionada.'),
          SizedBox(height: 16,),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nome')),
                DataColumn(label: Text('Função')),
                DataColumn(label: Text('Início')),
                DataColumn(label: Text('Término')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('João Silva')),
                  DataCell(Text('Repositor')),
                  DataCell(Text('08:00')),
                  DataCell(Text('16:00')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Maria Souza')),
                  DataCell(Text('Caixa')),
                  DataCell(Text('09:00')),
                  DataCell(Text('17:00')),
                ]),
                // Adicione mais linhas conforme necessário
              ],
            ),
          ),
        ],
      )
      ),
    );
  }
}