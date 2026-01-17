import 'package:flutter/material.dart';
import 'package:freelance/helpers/datetime_helper.dart';
import 'package:freelance/models/request.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:freelance/services/status_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final _formKey = GlobalKey<FormState>();

  DateTime? dataInicio;
  DateTime? dataFim;

  String valuedropDonw = setores[0];

  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  String setorSelecionado = setores[0];

  @override
  void dispose() {
    quantidadeController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  void _submeter() {
    if (!_formKey.currentState!.validate()) return;

    if (dataInicio == null || dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data de início e fim')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final pedidoProvider = context.read<PedidoProvider>();

    if (auth.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }

    final novoPedido = PedidoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lojaId: auth.user!.lojaId,
      gerenteId: auth.user!.id,
      dataInicio: dataInicio!,
      dataFim: dataFim!,
      funcao: valuedropDonw,
      quantidade: int.parse(quantidadeController.text),
      observacoes: observacaoController.text,
      status: StatusPedido.solicitado.name,
      dataCriacao: DateTime.now(),
    );

    pedidoProvider.adicionarPedido(novoPedido);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitação enviada ao RH')));

    context.pop();
  }

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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Função
                        DropdownButton<String>(
                          hint: Text('Selecione a Função'),
                          isExpanded: true,
                          value: valuedropDonw,
                          items: setores.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              valuedropDonw = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quantidade
                        TextFormField(
                          controller: quantidadeController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obrigatorio";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de Pessoas',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Data/hora início
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Horario de inicio',
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                              dataInicio == null ? 'Campo obrigatório' : null,
                          onTap: () async {
                            final result = await selecionarDataHora(
                              context: context,
                              initialDate: dataInicio,
                            );
                            if (result != null) {
                              setState(() {
                                dataInicio = result;
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: dataInicio == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(dataInicio!),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Data/hora fim
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Hora fim',
                            border: OutlineInputBorder(),
                          ),
                          validator: (_) =>
                              dataFim == null ? 'Campo obrigatório' : null,
                          onTap: () async {
                            final result = await selecionarDataHora(
                              context: context,
                              initialDate: dataFim,
                            );
                            if (result != null) {
                              setState(() {
                                dataFim = result;
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: dataFim == null
                                ? ''
                                : DateFormat('dd/MM/yyyy').format(dataFim!),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Observações
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Campo obrigatorio";
                            }
                            return null;
                          },
                          controller: observacaoController,
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
                    _submeter();
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
