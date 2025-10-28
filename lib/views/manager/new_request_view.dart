import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<String> setores = [
  'Reposição',
  'Limpeza',
  'Açougue',
  'Segurança',
  'Cozinha',
  'Frios',
  'Operador de Caixa',
  'Fiscal de Loja',
  'Fiscal de caixa',
  'Motorista',
  'Estoquista',
  'Ajudante de Carga e Descarga',
  'CPD',
  'Padaria',
  'Salgados',
];

class NovaSolicitacao extends StatefulWidget {
  const NovaSolicitacao({super.key});

  @override
  State<NovaSolicitacao> createState() => _NovaSolicitacaoState();
}

class _NovaSolicitacaoState extends State<NovaSolicitacao> {
  String valuedropDonw = setores[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // volta para a tela anterior
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Criar Pedido de Pessoal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Card principal do formulário
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Função
                    DropdownButton<String>(
                      hint: Text('Selecione a Função'),
                      isExpanded: true,
                      value: valuedropDonw,
                      items: setores.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          valuedropDonw = value!;
                        });
                      },),
                      const SizedBox(height: 16),

                      // Quantidade
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de Pessoas',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Data/hora início
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Data/Horário de Início',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Data/hora fim
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Data/Horário de Término',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botão principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Enviar para RH',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Solicitação enviada ao RH.')),
                    );
                    context.pop(); // volta à tela anterior
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
