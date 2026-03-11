import 'package:flutter/material.dart';
import 'package:freelance/helpers/datetime_helper.dart';
import 'package:freelance/models/pedido_model.dart';
import 'package:freelance/providers/auth_provider.dart';
import 'package:freelance/providers/funcao_provider.dart';
import 'package:freelance/providers/loja_provider.dart';
import 'package:freelance/providers/pedido_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NovaSolicitacao extends StatefulWidget {
  const NovaSolicitacao({super.key});

  @override
  State<NovaSolicitacao> createState() => _NovaSolicitacaoState();
}

class _NovaSolicitacaoState extends State<NovaSolicitacao> {
  final _formKey = GlobalKey<FormState>();

  String? _funcaoSelecionada;
  String? _lojaSelecionada;

  DateTime? dataInicio;
  DateTime? dataFim;

  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carrega lojas e funções ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LojaProvider>().fetchLojas();
      context.read<FuncaoProvider>().fetchFuncoes();
    });
  }

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

    if (_funcaoSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma função')));
      return;
    }

    if (_lojaSelecionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma loja')));
      return;
    }

    final auth = context.read<AuthProvider>();

    if (auth.user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não logado')));
      return;
    }

    final novoPedido = PedidoModel(
      id: '', // gerado pelo Supabase
      lojaId: _lojaSelecionada!,
      gerenteId: auth.user!.id,
      funcaoId: _funcaoSelecionada!,
      dataInicio: dataInicio!,
      dataFim: dataFim!,
      quantidade: int.parse(quantidadeController.text),
      observacoes: observacaoController.text,
      status: 'solicitado',
      dataCriacao: DateTime.now(),
    );

    context.read<PedidoProvider>().adicionarPedido(novoPedido);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solicitação enviada ao RH')));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final funcoes = context.watch<FuncaoProvider>().funcoes;
    final lojas = context.watch<LojaProvider>().lojas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                        // Loja
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Loja',
                            border: OutlineInputBorder(),
                          ),
                          value: _lojaSelecionada,
                          hint: Text(
                            lojas.isEmpty
                                ? 'Carregando lojas...'
                                : 'Selecione a loja',
                          ),
                          items: lojas.map((loja) {
                            return DropdownMenuItem<String>(
                              value: loja.id,
                              child: Text(loja.nomeLoja),
                            );
                          }).toList(),
                          onChanged: lojas.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _lojaSelecionada = value);
                                },
                          validator: (value) =>
                              value == null ? 'Selecione uma loja' : null,
                        ),
                        const SizedBox(height: 16),

                        // Função
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Função',
                            border: OutlineInputBorder(),
                          ),
                          value: _funcaoSelecionada,
                          hint: Text(
                            funcoes.isEmpty
                                ? 'Nenhuma função cadastrada'
                                : 'Selecione a função',
                          ),
                          items: funcoes.map((funcao) {
                            return DropdownMenuItem<String>(
                              value: funcao.funcaoId,
                              child: Text(funcao.nomeFuncao),
                            );
                          }).toList(),
                          onChanged: funcoes.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _funcaoSelecionada = value);
                                },
                          validator: (value) =>
                              value == null ? 'Selecione uma função' : null,
                        ),
                        const SizedBox(height: 16),

                        // Quantidade
                        TextFormField(
                          controller: quantidadeController,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Campo obrigatório'
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de Pessoas',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        // Data início
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Horário de Início',
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
                              setState(() => dataInicio = result);
                            }
                          },
                          controller: TextEditingController(
                            text: dataInicio == null
                                ? ''
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(dataInicio!),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Data fim
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Data/Hora Fim',
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
                              setState(() => dataFim = result);
                            }
                          },
                          controller: TextEditingController(
                            text: dataFim == null
                                ? ''
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(dataFim!),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Observações
                        TextFormField(
                          controller: observacaoController,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Campo obrigatório'
                              : null,
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
                  onPressed: _submeter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
